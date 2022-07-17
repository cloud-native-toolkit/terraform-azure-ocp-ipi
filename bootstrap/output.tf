output "bootstrap_public_ip" {
    value       = data.azurerm_public_ip.bootstrap_public_ip
    description = "Public IP assigned to the bootstrap node"
}