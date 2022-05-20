module "azure-ocp-ipi" {
  source = "./module"

  name_prefix = var.name_prefix
  domain_resource_group_name = "ocp-ipi-rg"  
  region = var.region
  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret
  tenant_id = var.tenant_id
  pull_secret = var.pull_secret
  base_domain = "clusters.azure.ibm-software-everywhere.dev"
}
