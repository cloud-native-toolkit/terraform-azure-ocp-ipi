#output "myoutput" {
#  description = "Description of my output"
#  value       = "value"
#  depends_on  = [<some resource>]
#}

// temporary output
output "installer_uri" {
  description = "Installer URL"
  value = local.installer_url
}