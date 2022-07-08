/*

output "id" {
  value       = data.external.oc_info.result.clusterID
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
    data.external.oc_info
  ]
}

output "consoleURL" {
  value       = data.external.oc_info.result.consoleURL
  description = "URL for the cluster console"
}

output "server_url" {
  value       = data.external.oc_info.result.serverURL
  description = "The url used to connect to the api of the cluster."
}

output "username" {
  value       = data.external.oc_info.result.kubeadminUsername
  description = "kubeadmin username for the cluster"
}

output "password" {
  value       = data.external.oc_info.result.kubeadminPassword
  description = "kubeadmin password for the cluster"
  sensitive   = true
}

output "token" {
  description = "The admin user token used to generate the cluster"
  value = ""
  sensitive = true
}

output "bin_dir" {
  value       = local.binary_path
  description = "Path to the client binaries"
}

output "platform" {
  value = {
    id         = data.external.oc_info.result.clusterID
    kubeconfig = "${local.install_path}/auth/kubeconfig"
    server_url = data.external.oc_info.result.serverURL
    type       = local.cluster_type
    type_code  = local.cluster_type_code
    version    = local.cluster_version
    ingress    = data.external.oc_info.result.consoleURL
    tls_secret = data.external.oc_info.result.serverToken
  }
  sensitive = true
  description = "Configuration values for the created cluster platform"
  depends_on = [
    data.external.oc_info
  ]
}

*/
