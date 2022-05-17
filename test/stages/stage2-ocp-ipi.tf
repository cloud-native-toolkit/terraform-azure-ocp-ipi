module "azure-ocp-ipi" {
  source = "./module"

  name_prefix = var.name_prefix
  resource_group_name = "ocp-ipi-rg"  
  region = "eastus"
  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret
  tenant_id = var.tenant_id
  pull_secret_file = var.pull_secret_file
  base_domain = "clusters.azure.ibm-software-everywhere.dev"
}
