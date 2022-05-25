output "id" {
  value       = data.external.oc_login.result.clusterID
  description = "ID of the cluster"
}

output "name" {
  value       = local.cluster_name
  description = "Name of the cluster."
}

output "resource_group_name" {
  value       = data.external.oc_info.result.infraID
  description = "Name of the resource group containing the cluster"
  depends_on  = [
    data.external.oc_info
  ]
}

output "region" {
  value       = var.region
  description = "Azure location containing the cluster"
  depends_on  = [
    data.external.oc_info
  ]
}

output "config_file_path" {
  value       = "${local.install_path}/auth/kubeconfig"
  description = "Path to the config file for the cluster."
  depends_on  = [
    data.external.oc_login
  ]
}

output "consoleURL" {
  value       = data.external.oc_info.result.consoleURL
  description = "URL for the cluster console"
}

output "username" {
  value       = data.external.oc_info.result.kubeadminUsername
  description = "kubeadmin username for the cluster URL"
}

output "password" {
  value       = data.external.oc_info.result.kubeadminPassword
  description = "kubeadmin password for the cluster URL"
  sensitive   = true
}

output "bin_dir" {
  value       = local.binary_path
  description = "Path to the client binaries"
  depends_on = [
    null_resource.binary_download
  ]
}

