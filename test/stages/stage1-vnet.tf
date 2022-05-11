module "main_resource_group" {
  source = "github.com/cloud-native-toolkit/terraform-azure-resource-group"

  resource_group_name = var.resource_group_name
  region              = var.region
  enabled             = var.enabled
}

module "nw_resource_group" {
  source = "github.com/cloud-native-toolkit/terraform-azure-resource-group"

  resource_group_name = var.nw_resource_group_name
  region              = var.region
  enabled             = var.enabled
}

module "vnet" {
  source = "github.com/cloud-native-toolkit/terraform-azure-vnet"

  resource_group_name = module.nw_resource_group.name
  region              = var.region
  name_prefix         = var.name_prefix
  address_prefix_count = 1
  address_prefixes    = ["10.0.0.0/16"]
  enabled             = module.nw_resource_group.enabled
}

module "master-subnets" {
  source = "github.com/cloud-native-toolkit/terraform-azure-subnets"

  resource_group_name = module.nw_resource_group.name
  region = var.region
  vpc_name = module.vnet.name
  _count = 2
  ipv4_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
  enabled = var.enabled
  acl_rules = []
}

module "worker-subnets" {
  source = "github.com/cloud-native-toolkit/terraform-azure-subnets"

  resource_group_name = module.nw_resource_group.name
  region = var.region
  vpc_name = module.vnet.name
  _count = 2
  ipv4_cidr_blocks = ["10.0.64.0/24", "10.0.65.0/24"]
  enabled = var.enabled
  acl_rules = []
}

resource null_resource print_enabled {
  provisioner "local-exec" {
    command = "echo -n '${module.subnets.enabled}' > .enabled"
  }
}