module "ssh-key" {
  source = "github.com/cloud-native-toolkit/terraform-azure-ssh-key?ref=v1.0.2"

  key_name = "test"
  resource_group_name = module.resource_group.name
  region = var.region
  store_path = "install"
  store_key_in_vault = false
}
