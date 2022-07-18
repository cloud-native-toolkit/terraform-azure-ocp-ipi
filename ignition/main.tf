locals {
  worker_nodes_per_zone  = [for idx in range(length(var.availability_zones)) : floor(var.worker_node_qty / length(var.availability_zones)) + (idx + 1 > (var.worker_node_qty % length(var.availability_zones)) ? 0 : 1)]
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"

  bin_dir = var.bin_dir
  clis    = ["openshift-install-${var.openshift_version}","jq","oc"]
}

// Create storage account for ignition files
resource "azurerm_storage_account" "ignition" {
  name                      = "ignition${var.cluster_id}"
  resource_group_name       = var.resource_group_name
  location                  = var.region
  account_tier              = var.storage_account_tier
  account_replication_type  = var.storage_account_replication_type
}

// Get the shared access signature (SAS) for the created storage account
data "azurerm_storage_account_sas" "ignition" {
  connection_string = azurerm_storage_account.ignition.primary_connection_string
  https_only        = true
  start             = timestamp()
  expiry            = timeadd(timestamp(), "24h")

  resource_types {
    service     = false
    container   = false
    object      = true
  }

  services {
    blob    = true
    queue   = false
    table   = false
    file    = false
  }

  permissions {
    read    = true
    list    = true
    create  = false
    add     = false
    delete  = false
    process = false
    write   = false
    update  = false
    filter  = false
    tag     = false
  }
}

// Create storage container
resource "azurerm_storage_container" "ignition" {
  name                  = "ignition"
  storage_account_name  = azurerm_storage_account.ignition.name
  container_access_type = "private"
}

// Add Azure credentials to config file
resource "local_file" "azure_config" {
  content = templatefile("${path.module}/templates/osServicePrincipal.json.tftpl",{
      subscription_id   = var.subscription_id,
      client_id         = var.client_id,
      client_secret     = var.client_secret,
      tenant_id         = var.tenant_id
  })
  filename = pathexpand("~/.azure/osServicePrincipal.json")
  file_permission = "0600"
}

// Create the install-config.yaml file
resource "local_file" "install_config" {
  content  = templatefile("${path.module}/templates/install_config.tftpl", {
      CLUSTER_NAME                  = var.cluster_name
      BASE_DOMAIN                   = var.base_domain
      MASTER_HYPERTHREADING         = var.master_hyperthreading
      MASTER_ARCHITECTURE           = var.master_architecture
      MASTER_NODE_DISK_SIZE         = var.master_node_disk_size
      MASTER_NODE_DISK_TYPE         = var.master_node_disk_type
      MASTER_NODE_TYPE              = var.master_node_type
      MASTER_NODE_QTY               = var.master_node_qty
      WORKER_HYPERTHREADING         = var.worker_hyperthreading
      WORKER_ARCHITECTURE           = var.worker_architecture
      WORKER_NODE_TYPE              = var.worker_node_type
      WORKER_NODE_DISK_SIZE         = var.worker_node_disk_size
      WORKER_NODE_DISK_TYPE         = var.worker_node_disk_type
      WORKER_NODE_QTY               = var.worker_node_qty
      CLUSTER_CIDR                  = var.cluster_cidr
      CLUSTER_HOST_PREFIX           = var.cluster_host_prefix
      MACHINE_CIDR                  = var.machine_cidr
      NETWORK_TYPE                  = var.network_type
      SERVICE_NETWORK_CIDR          = var.service_network_cidr
      DOMAIN_RESOURCE_GROUP_NAME    = var.domain_resource_group_name
      NETWORK_RESOURCE_GROUP_NAME   = var.network_resource_group_name
      REGION                        = var.region
      VNET_NAME                     = var.vnet_name
      MASTER_SUBNET_NAME            = var.master_subnet_name
      WORKER_SUBNET_NAME            = var.worker_subnet_name
      OUTBOUND_TYPE                 = var.outbound_type
      PULL_SECRET                   = var.pull_secret
      ENABLE_FIPS                   = var.enable_fips
      PUBLIC_SSH_KEY                = var.public_ssh_key
    })
  filename = "${var.install_path}/install-config.yaml"
  file_permission = "0664"
}

// Generate ignition manifests
resource "null_resource" "generate_manifests" {
  depends_on = [
    local_file.install_config
  ]

  triggers = {
    binary_path = module.setup_clis.bin_dir
    install_path = var.install_path
  }

  provisioner "local-exec" {
    when = create
    
    command = "${path.module}/scripts/generate-manifests.sh"

    environment = {
      BIN_DIR = "${self.triggers.binary_path}"
      INSTALL_DIR = "${self.triggers.install_path}"
     }
  }

  provisioner "local-exec" {
    when = destroy

    command = "${path.module}/scripts/destroy-manifests.sh"

    environment = {
      INSTALL_DIR = "${self.triggers.install_path}" 
    }
  }
}

// Create infrastructure config file
resource "local_file" "cluster-infrastructure-config" {
  depends_on = [
    null_resource.generate_manifests
  ]

  content = templatefile("${path.module}/templates/cluster-infrastructure-02-config.tftpl", {
    CLUSTER_NAME        = var.cluster_name
    BASE_DOMAIN         = var.base_domain
    CLUSTER_INFRA_NAME  = var.cluster_infra_name
    RESOURCE_GROUP_NAME = var.resource_group_name
  })
  filename = "${var.install_path}/manifests/cluster-infrastructure-02-config.yml"
  file_permission = "0664"
}

// Create DNS config file
resource "local_file" "cluster-dns-config" {
  depends_on = [
    null_resource.generate_manifests
  ]

  content = templatefile("${path.module}/templates/cluster-dns-02-config.tftpl", {
    CLUSTER_NAME                = var.cluster_name
    BASE_DOMAIN                 = var.base_domain
    SUBSCRIPTION_ID             = var.subscription_id
    RESOURCE_GROUP_NAME         = var.resource_group_name  
    DOMAIN_RESOURCE_GROUP_NAME  = var.domain_resource_group_name  
  })
  filename = "${var.install_path}/manifests/cluster-dns-02-config.yml"
  file_permission = "0664"
}

// Create cloud provider config
resource "local_file" "cloud-provider-config" {
  depends_on = [
    null_resource.generate_manifests
  ]

  content = templatefile("${path.module}/templates/cloud-provider-config.tftpl", {
    TENANT_ID                   = var.tenant_id
    SUBSCRIPTION_ID             = var.subscription_id
    RESOURCE_GROUP_NAME         = var.resource_group_name
    REGION                      = var.region
    VNET_NAME                   = var.vnet_name
    NETWORK_RESOURCE_GROUP_NAME = var.network_resource_group_name
    WORKER_SUBNET_NAME          = var.worker_subnet_name
    NSG_NAME                    = var.nsg_name
    CLUSTER_INFRA_NAME          = var.cluster_infra_name
  })
  filename = "${var.install_path}/manifests/cloud-provider-config.yaml"
  file_permission = "0664"
}

// Create master node config
resource "local_file" "master-node-config" { 
  count = var.master_node_qty

  depends_on = [
    null_resource.generate_manifests
  ]

  content = templatefile("${path.module}/templates/openshift-cluster-api_master-machines.tftpl", {
    CLUSTER_INFRA_NAME          = var.cluster_infra_name
    COUNT                       = "${count.index}"
    RESOURCE_GROUP_NAME         = var.resource_group_name
    CLUSTER_INFRA_NAME          = var.cluster_infra_name
    REGION                      = var.region
    NETWORK_RESOURCE_GROUP_NAME = var.network_resource_group_name
    MASTER_NODE_DISK_SIZE       = var.master_node_disk_size
    MASTER_NODE_DISK_TYPE       = var.master_node_disk_type
    MASTER_SUBNET_NAME          = var.master_subnet_name
    MASTER_NODE_TYPE            = var.master_node_type
    VNET_NAME                   = var.vnet_name
    ZONE                        = length(var.availability_zones) > 1 ? "${var.availability_zones[count.index]}" : "1"
  })
  filename = "${var.install_path}/openshift/99_openshift-cluster-api_master-machines-${count.index}.yaml"
  file_permission = "0664"

}

// Create worker node machinesets
resource "local_file" "worker-node-machinesets" {
  count = length(var.availability_zones)

  depends_on = [
    null_resource.generate_manifests
  ]

  content = templatefile("${path.module}/templates/openshift-cluster-api_worker-machineset.tftpl", {
    CLUSTER_INFRA_NAME = var.cluster_infra_name   
    REGION = var.region
    COUNT = "${count.index + 1}"
    REPLICAS = local.worker_nodes_per_zone[count.index] 
    RESOURCE_GROUP_NAME = var.resource_group_name
    NETWORK_RESOURCE_GROUP_NAME = var.network_resource_group_name
    WORKER_NODE_DISK_SIZE   = var.worker_node_disk_size
    WORKER_NODE_DISK_TYPE = var.worker_node_disk_type
    WORKER_SUBNET_NAME = var.worker_subnet_name
    WORKER_NODE_TYPE = var.worker_node_type
    VNET_NAME = var.vnet_name
    ZONE = length(var.availability_zones) > 1 ? "${var.availability_zones[count.index]}" : "1"
  })
  filename = "${var.install_path}/openshift/99_openshift-cluster-api_worker-machineset-${count.index}.yaml"
  file_permission = "0664"
}

// Create cloud credentials secret
resource "local_file" "cloud-credentials-secret" {
  depends_on = [
      null_resource.generate_manifests
  ]

  content = templatefile("${path.module}/templates/cloud-creds-secret-kube-system.tftpl", {
    SUBSCRIPTION_ID = base64encode(var.subscription_id)
    CLIENT_ID = base64encode(var.client_id)
    CLIENT_SECRET = base64encode(var.client_secret)
    TENANT_ID = base64encode(var.tenant_id)
    CLUSTER_INFRA_NAME = base64encode(var.cluster_infra_name)
    RESOURCE_GROUP_NAME = base64encode(var.resource_group_name)
    REGION = base64encode(var.region)
  })
  filename = "${var.install_path}/openshift/99_cloud-creds-secret.yaml"
  file_permission = "0664"
}

// Create ignition configurations
resource "null_resource" "create_ignition_configs" {
  depends_on = [
    null_resource.generate_manifests,
    local_file.cluster-infrastructure-config,
    local_file.cluster-dns-config,
    local_file.cloud-provider-config,
    local_file.master-node-config,
    local_file.worker-node-machinesets,
    local_file.cloud-credentials-secret
  ]

  triggers = {
    binary_path = module.setup_clis.bin_dir
    install_path = var.install_path
    cluster_infra_name = var.cluster_infra_name
  }

  provisioner "local-exec" {
    when = create

    command = "${path.module}/scripts/create-ignition.sh"

    environment = {
      BIN_DIR = "${self.triggers.binary_path}"
      INSTALL_PATH = "${self.triggers.install_path}"
      CLUSTER_INFRA_NAME = "${self.triggers.cluster_infra_name}"
    }
  }

  provisioner "local-exec" {
    when = destroy
    
    command = "${path.module}/scripts/destroy-ignition.sh"

    environment = {
      INSTALL_PATH = "${self.triggers.install_path}"
    }
  }

}

// Read ignition content for bootstrap activities
resource "azurerm_storage_blob" "ignition-bootstrap" {
  name                   = "bootstrap.ign"
  source                 = "${var.install_path}/bootstrap.ign"
  storage_account_name   = azurerm_storage_account.ignition.name
  storage_container_name = azurerm_storage_container.ignition.name
  type                   = "Block"
  #depends_on = [
  #  null_resource.create_ignition_configs
  #]
}

resource "azurerm_storage_blob" "ignition-master" {
  name                   = "master.ign"
  source                 = "${var.install_path}/master.ign"
  storage_account_name   = azurerm_storage_account.ignition.name
  storage_container_name = azurerm_storage_container.ignition.name
  type                   = "Block"
  #depends_on = [
  #  null_resource.create_ignition_configs
  #]
}

resource "azurerm_storage_blob" "ignition-worker" {
  name                   = "worker.ign"
  source                 = "${var.install_path}/worker.ign"
  storage_account_name   = azurerm_storage_account.ignition.name
  storage_container_name = azurerm_storage_container.ignition.name
  type                   = "Block"
  #depends_on = [
  #  null_resource.create_ignition_configs
  #]
}

data "ignition_config" "master_redirect" {
  replace {
    source = "${azurerm_storage_blob.ignition-master.url}${data.azurerm_storage_account_sas.ignition.sas}"
  }
}

data "ignition_config" "bootstrap_redirect" {
  replace {
    source = "${azurerm_storage_blob.ignition-bootstrap.url}${data.azurerm_storage_account_sas.ignition.sas}"
  }
}

data "ignition_config" "worker_redirect" {
  replace {
    source = "${azurerm_storage_blob.ignition-worker.url}${data.azurerm_storage_account_sas.ignition.sas}"
  }
}
