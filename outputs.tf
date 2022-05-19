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