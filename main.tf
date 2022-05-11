
locals {
  cluster_id = "${random_string.cluster_id.result}"
  cluster_name = "${var.name_prefix}-${local.cluster_id}"
  tags = merge(
    {
      "kubernetes.io_cluster.${local.cluster_name}" = "owned"
    }
       // TODO: add ability to append tags
  )
  major_version     = join(".", slice(split(".", var.openshift_version), 0, 2))
  install_path      = var.install_path == "./install" ? "${path.root}/install" : var.install_path
  installer_url     = "${var.installer_url}/${var.openshift_version}/"
}

// Create a random string of 5 lowercase letters for the cluster id
resource "random_string" "cluster_id" {
  length = 5
  special = false
  upper = false
}

// Configure DNS records
resource "azurerm_dns_zone" "ocp" {
  name = var.base_domain
  resource_group_name = var.resource_group_name
}


// Ensure roles are assigned

/*
resource "azurerm_user_assigned_identity" "main" {
  name                = "${local.cluster_name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.region
}

resource "azurerm_role_assignment" "main" {
  scope     = var.resource_group_id
  role_definition_name = "Contributer"
  principal_id = azurerm_user_assigned_identity.main.principal_id
}

*/

// Download the installer and cli

// Create the install-config.yaml file
resource "local_file" "install_config" {
  content  = templatefile("${path.module}/templates/install_config.tftpl", {
      cluster_name = local.cluster_name,
      base_domain = var.base_domain,
      credentials_mode = var.credentials_mode,
      master_hyperthreading = var.master_hyperthreading,
      master_node_disk_size = var.master_node_disk_size,
      master_node_disk_type = var.master_node_disk_type,
      master_node_type = var.master_node_type,
      master_node_qty = var.master_node_qty,
      worker_hyperthreading = var.worker_hyperthreading,
      worker_node_type = var.worker_node_type,
      worker_node_disk_size = var.worker_node_disk_size,
      worker_node_disk_type = var.worker_node_disk_type,
      worker_node_qty = var.worker_node_qty,
      cluster_cidr = var.cluster_cidr,
      cluster_host_prefix = var.cluster_host_prefix,
      machine_cidr = var.machine_cidr,
      network_type = var.network_type,
      service_network_cidr = var. service_network_cidr,
      resource_group_name = var.resource_group_name,
      network_resource_group_name = var.network_resource_group_name,
      region = var.region,
      vnet_name = var.vnet_name,
      master_subnet_name = var.master_subnet_name,
      worker_subnet_name = var.worker_subnet_name,
      outbound_type = var.outbound_type,
      pull_secret = "${chomp(file(var.pull_secret_file))}",
      enable_fips = var.enable_fips,
      public_ssh_key = var.openshift_ssh_key
      })
  filename = "${local.install_path}/install-config.yaml"
}

// Run openshift-installer and clean up bootstrap