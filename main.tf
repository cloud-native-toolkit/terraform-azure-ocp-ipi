
locals {
  # Cluster id only needed for UPI
  # cluster_id = "${random_string.cluster_id.result}"
  cluster_name = var.name_prefix
  base_domain = var.base_domain
  tags = merge(
    {
      "kubernetes.io_cluster.${local.cluster_name}" = "owned"
    }
       // TODO: add ability to append tags
  )
  major_version     = join(".", slice(split(".", var.openshift_version), 0, 2))
  binary_path       = module.setup_clis.bin_dir
  install_path      = "${path.cwd}/${var.install_offset}"
  pull_secret       = var.pull_secret_file != "" ? "${chomp(file(var.pull_secret_file))}" : var.pull_secret
  cluster_type      = "openshift"
  cluster_type_code = "ocp4"
  cluster_version   = "${data.external.oc_info.result.serverVersion}_openshift"
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
