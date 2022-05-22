#output "myoutput" {
#  description = "Description of my output"
#  value       = "value"
#  depends_on  = [<some resource>]
#}

// temporary output
output "consoleURL" {
    value = data.external.oc_info.result.consoleURL
}

output "kubeadminUsername" {
    value = data.external.oc_info.result.kubeadminUsername
}

output "kubeadminPassword" {
    value = data.external.oc_info.result.kubeadminPassword
    # sensitive = true
}

output "clusterID" {
  value = data.external.oc_login.result.clusterID
}

output "infraID" {
  value = data.external.oc_info.result.infraID
}

output "bin_dir" {
  value = local.binary_path
}

output "config_file_path" {
  value = "${local.install_path}/auth/kubeconfig"
}