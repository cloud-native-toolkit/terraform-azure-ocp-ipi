
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
  install_path      = var.install_path == "./install" ? "${path.root}/install" : var.install_path
}

// Create a random string of 5 lowercase letters for the cluster id
// Only required for UPI
/*
resource "random_string" "cluster_id" {
  length = 5
  special = false
  upper = false
}
*/

// Configure DNS records
/*
resource "azurerm_dns_zone" "ocp" {
  name = local.base_domain
  resource_group_name = var.network_resource_group_name
}
*/

// TODO
// Ensure roles are assigned

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
resource "null_resource" "binary_download" {
  provisioner "local-exec" {
    when = create
    command = templatefile("${path.module}/templates/cli-download.sh.tftpl", {
        binary_path = "binaries"
        binary_url = var.binary_url_base
        ocp_version = var.openshift_version
    })
  
  }

  provisioner "local-exec" {
    when = destroy
    command = "rm -rf ${path.root}/binaries"
  }
}


// Create the install-config.yaml file

resource "local_file" "install_config" {
  content  = templatefile("${path.module}/templates/install_config.tftpl", {
      existing_network = var.network_resource_group_name != "" ? true : false,
      cluster_name = local.cluster_name,
      base_domain = local.base_domain,
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
  file_permission = "0664"
}

// Run openshift-installer and clean up bootstrap

resource "null_resource" "openshift-install" {
  depends_on = [
      local_file.install_config,
      null_resource.binary_download,
      local_file.azure_config
  ]

  provisioner "local-exec" {
    when = create
    command = "cd ${path.root}/install ; ${path.root}/binaries/openshift-install create cluster --dir ./"
    # command = "echo ${path.root}/binaries/openshift-install create cluster --dir ${path.root}/install/"  
  }

  provisioner "local-exec" {
    when = destroy
    command = "cd {path.root}/install ; ${path.root}/binaries/openshift-install destroy cluster --dir ./"
    # command = "echo ${path.root}/binaries/openshift-install destroy cluster --dir ${path.root}/install/"
  }
}
