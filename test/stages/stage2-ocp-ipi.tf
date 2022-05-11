module "azure-ocp-ipi" {
  source = "./module"

  name_prefix = var.name_prefix
  resource_group_name = module.main_resource_group.name  
  network_resource_group_name = module.nw_resource_group.name
  resource_group_id = module.main_resource-group.id
  vnet_name = module.azure-vnet.name
  region = var.region
  master_subnet_name = "module.master-subnets.name"
  worker_subnet_name = "module.worker-subnets.name"
  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret
  tenant_id = var.tenant_id
  pull_secret_file = "xyzzy"
  openshift_ssh_key = module.ssh-key.pub_key
  machine_cidr = module.azure-vnet.addresses[0]
  base_domain = "${var.name_prefix}.azure.ibm-software-everywhere.dev"
}
