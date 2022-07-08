
locals {
  cluster_id = "${random_string.cluster_id.result}"
  cluster_name = var.name_prefix
  base_domain = var.base_domain

  tags = merge(
    {
      "kubernetes.io_cluster.${local.cluster_name}" = "owned"
    }
       // TODO: add ability to append tags
  )
  
  existing_network  = var.network_resource_group_name == "" ? false : true

  rhcos_image       = lookup(lookup(jsondecode(data.http.images.body), "azure"), "url")

  major_version     = join(".", slice(split(".", var.openshift_version), 0, 2))
  binary_path       = module.setup_clis.bin_dir
  install_path      = "${path.cwd}/${var.install_offset}"
  pull_secret       = var.pull_secret_file != "" ? "${chomp(file(var.pull_secret_file))}" : var.pull_secret
  cluster_type      = "openshift"
  cluster_type_code = "ocp4"
  // cluster_version   = "${data.external.oc_info.result.serverVersion}_openshift"
}

// Construct the cluster_id to uniquely identify the cluster even if the same name_prefix is provided
resource "random_string" "cluster_id" {
    length = 5
    special = false
    upper = false
}

// Add Azure credentials to config file
resource "local_file" "azure_config" {
  content = templatefile("${path.module}/templates/osServicePrincipal.json.tftpl",{
      subscription_id = var.subscription_id,
      client_id = var.client_id,
      client_secret = var.client_secret,
      tenant_id = var.tenant_id
  })
  filename = pathexpand("~/.azure/osServicePrincipal.json")
  file_permission = "0600"
}

// Download the installer and cli
module setup_clis {
    source = "github.com/cloud-native-toolkit/terraform-util-clis.git"

    bin_dir = "${path.cwd}/${var.binary_offset}"
    clis = ["openshift-install-${var.openshift_version}","jq","yq4","oc"]
}

// Either create the VNet or get details of existing
module "vnet" {
  source = "./vnet"

  existing_network            = local.existing_network
  name_prefix                 = var.name_prefix
  region                      = var.region
  cluster_id                  = local.cluster_id
  vnet_cidrs                  = var.vnet_cidrs
  network_resource_group      = var.network_resource_group_name
  existing_vnet_name          = var.vnet_name
  existing_master_subnet_name = var.master_subnet_name
  existing_worker_subnet_name = var.worker_subnet_name
}

// Obtain existing resource group id where applicable
data "azurerm_resource_group" "network" {
  count = local.existing_network ? 1 : 0

  name = module.vnet.network_resource_group_name
}

// Create a set of SSH keys for access to the cluster
module "ssh_keys" {
  source = "github.com/cloud-native-toolkit/terraform-azure-ssh-key"

  key_name            = var.ssh_key_name
  resource_group_name = module.vnet.resource_group_name
  region              = var.region
  store_path          = local.install_path
  store_key_in_vault  = false
}

// Create user assigned identity and give permissions
resource "azurerm_user_assigned_identity" "cluster" {
  resource_group_name = module.vnet.resource_group_name
  location            = var.region
  name                = "${var.name_prefix}-${local.cluster_id}-identity"
}

resource "azurerm_role_assignment" "cluster" {
  scope                 = module.vnet.resource_group_id
  role_definition_name  = "Contributor"
  principal_id          = azurerm_user_assigned_identity.cluster.principal_id
}

resource "azurerm_role_assignment" "network" {
  count = local.existing_network ? 1 : 0

  scope                 = data.azurerm_resource_group.network[0].id
  role_definition_name  = "Contributor"
  principal_id          = azurerm_user_assigned_identity.cluster.principal_id
}

// Create the storage account
resource "azurerm_storage_account" "cluster" {
  name                      = "cluster${replace(var.name_prefix, "-", "")}${local.cluster_id}"
  resource_group_name       = module.vnet.resource_group_name
  location                  = var.region
  account_tier              = var.storage_account_tier
  account_replication_type  = var.storage_account_replication_type
}

// Create the VM image
data "http" "images" {
  url = "https://raw.githubusercontent.com/openshift/installer/release-${local.major_version}/data/data/rhcos.json"
  request_headers = {
    Accept = "application/json"
  }
}

resource "azurerm_storage_container" "vhd" {
  name                  = "vhd${var.name_prefix}-${local.cluster_id}"
  storage_account_name  = azurerm_storage_account.cluster.name
}

resource "azurerm_storage_blob" "rhcos_image" {
  name                    = "rhcos${local.cluster_id}.vhd"
  storage_account_name    = azurerm_storage_account.cluster.name
  storage_container_name  = azurerm_storage_container.vhd.name
  type                    = "Page"
  source_uri              = local.rhcos_image
  metadata                = tomap({ "source_uri" = local.rhcos_image })
}

resource "azurerm_image" "cluster" {
  name                    = "${var.name_prefix}-${local.cluster_id}"
  resource_group_name     = module.vnet.resource_group_name
  location                = var.region

  os_disk {
    os_type   = "Linux"
    os_state  = "Generalized"
    blob_uri = azurerm_storage_blob.rhcos_image.url
  }
}

// Create bootstrap resources
module "bootstrap" {
  source = "./bootstrap"

  name_prefix         = var.name_prefix
  cluster_id          = local.cluster_id
  region              = var.region
  resource_group_name = module.vnet.resource_group_name
  subnet_id           = module.vnet.master_subnet_id
  nsg_name            = module.vnet.nsg_name
  vm_size             = var.bootstrap_type
  vm_image            = azurerm_image.cluster.id
  identity            = azurerm_user_assigned_identity.cluster.id
  storage_account     = azurerm_storage_account.cluster
}

// Create the install-config.yaml file

resource "local_file" "install_config" {
  content  = templatefile("${path.module}/templates/install_config.tftpl", {
      existing_network = var.network_resource_group_name != "" ? true : false,
      cluster_name = local.cluster_name
      base_domain = local.base_domain
      master_hyperthreading = var.master_hyperthreading
      master_architecture = var.master_architecture
      master_node_disk_size = var.master_node_disk_size
      master_node_disk_type = var.master_node_disk_type
      master_node_type = var.master_node_type
      master_node_qty = var.master_node_qty
      worker_hyperthreading = var.worker_hyperthreading
      worker_architecture = var.worker_architecture
      worker_node_type = var.worker_node_type
      worker_node_disk_size = var.worker_node_disk_size
      worker_node_disk_type = var.worker_node_disk_type
      worker_node_qty = var.worker_node_qty
      cluster_cidr = var.cluster_cidr
      cluster_host_prefix = var.cluster_host_prefix
      machine_cidr = var.machine_cidr
      network_type = var.network_type
      service_network_cidr = var. service_network_cidr
      resource_group_name = var.domain_resource_group_name
      network_resource_group_name = var.network_resource_group_name
      region = var.region
      vnet_name = var.vnet_name
      master_subnet_name = var.master_subnet_name
      worker_subnet_name = var.worker_subnet_name
      outbound_type = var.outbound_type
      pull_secret = local.pull_secret
      enable_fips = var.enable_fips
      public_ssh_key = var.openshift_ssh_key
    })
  filename = "${local.install_path}/install-config.yaml"
  file_permission = "0664"
}

// Run openshift-installer

resource "null_resource" "openshift-install" {
  depends_on = [
    local_file.install_config,
    local_file.azure_config
  ]

  triggers = {
    binary_path = local.binary_path
    install_path = local.install_path
  }

  provisioner "local-exec" {
    when = create
    command = templatefile("${path.module}/templates/ocp-create.sh.tftpl", {
      BINARY_PATH = "${self.triggers.binary_path}"
      WORKSPACE = "${self.triggers.install_path}"
    })  
  }

  provisioner "local-exec" {
    when = destroy
    command = templatefile("${path.module}/templates/ocp-destroy.sh.tftpl", {
      BINARY_PATH = "${self.triggers.binary_path}"
      WORKSPACE = "${self.triggers.install_path}"
    }) 
  }
}

data external "oc_info" {
  depends_on = [null_resource.openshift-install]

  program = ["bash", "${path.module}/scripts/oc-info.sh"]

  query = {
    bin_dir = local.binary_path
    log_file = "${local.install_path}/.openshift_install.log"
    metadata_file = "${local.install_path}/metadata.json"
    kubeconfig_file = "${local.install_path}/auth/kubeconfig"
  }
}
