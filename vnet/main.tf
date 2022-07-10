locals {
    resource_group      = var.existing_network ? var.network_resource_group : module.ocp_resource_group.name

    vnet_name           = var.existing_network ? var.existing_vnet_name : module.vnet[0].name

    master_cidr         = cidrsubnet(var.vnet_cidrs[0], 3, 0)
    worker_cidr         = cidrsubnet(var.vnet_cidrs[0], 3, 1)
}

module "ocp_resource_group" {
    source = "github.com/cloud-native-toolkit/terraform-azure-resource-group"

    resource_group_name = "${var.name_prefix}-${var.cluster_id}-rg"
    region              = var.region
}

module "vnet" {
    source = "github.com/cloud-native-toolkit/terraform-azure-vnet"
    count = var.existing_network ? 0 : 1

    resource_group_name     = local.resource_group
    region                  = var.region
    name                    = "${var.name_prefix}-${var.cluster_id}-vnet"
    address_prefix_count    = 1
    address_prefixes        = var.vnet_cidrs
}

data "azurerm_virtual_network" "vnet" {
    resource_group_name = local.resource_group
    name                = var.existing_network ? var.existing_vnet_name : module.vnet[0].name
}

module "master_subnet" {
    source = "github.com/cloud-native-toolkit/terraform-azure-subnets"
    count = var.existing_network ? 0 : 1

    resource_group_name = local.resource_group
    region              = var.region
    vpc_name            = data.azurerm_virtual_network.vnet.name
    subnet_name         = "${var.name_prefix}-${var.cluster_id}-master-subnet"
    _count              = 1
    ipv4_cidr_blocks    = ["${local.master_cidr}"]
    provision           = false
}

data "azurerm_subnet" "master_subnet" {
    resource_group_name     = local.resource_group
    virtual_network_name    = data.azurerm_virtual_network.vnet.name
    name                    = var.existing_network ? var.existing_master_subnet_name : module.master_subnet[0].names[0]
}

module "worker_subnet" {
    source = "github.com/cloud-native-toolkit/terraform-azure-subnets"
    count = var.existing_network ? 0 : 1

    resource_group_name = local.resource_group
    region              = var.region
    vpc_name            = data.azurerm_virtual_network.vnet.name
    subnet_name         = "${var.name_prefix}-${var.cluster_id}-worker-subnet"
    _count              = 1
    ipv4_cidr_blocks    = ["${local.worker_cidr}"]
    provision           = false
}

data "azurerm_subnet" "worker_subnet" {
    resource_group_name     = local.resource_group
    virtual_network_name    = data.azurerm_virtual_network.vnet.name
    name                    = var.existing_network ? var.existing_worker_subnet_name : module.worker_subnet[0].names[0]
}

resource "azurerm_network_security_group" "cluster" {
    name                    = "${var.name_prefix}-${var.cluster_id}-nsg"
    location                = var.region
    resource_group_name     = module.ocp_resource_group.name
}

resource "azurerm_subnet_network_security_group_association" "master" {
    subnet_id                   = data.azurerm_subnet.master_subnet.id
    network_security_group_id   = azurerm_network_security_group.cluster.id
}

resource "azurerm_subnet_network_security_group_association" "worker" {
    subnet_id                   = data.azurerm_subnet.worker_subnet.id
    network_security_group_id   = azurerm_network_security_group.cluster.id
}

resource "azurerm_network_security_rule" "api_inbound" {
  name                        = "api_bound"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "6443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.ocp_resource_group.name
  network_security_group_name = azurerm_network_security_group.cluster.name
}

// Load balancers

module "internal_lb" {
    source = "github.com/cloud-native-toolkit/terraform-azure-lb"

    name_prefix         = "${var.name_prefix}-${var.cluster_id}-internal-lb"
    resource_group_name = module.ocp_resource_group.name
    region              = var.region
    public              = false
    subnet_id           = data.azurerm_subnet.master_subnet.id
    lb_sku              = "Standard"
    use_ipv4            = true
    use_ipv6            = false

    lb_rules            = [{
        name = "${var.name_prefix}-api-internal-rule"
        protocol = "Tcp"
        probe_name = "${var.name_prefix}-api-internal-probe"
        frontend_port = 6443
        backend_port = 6443
        idle_timeout = 30
        load_distribution = "Default"
        enable_floating_point = false
    },
    {
        name = "${var.name_prefix}-sint-rule"
        protocol = "Tcp"
        probe_name = "${var.name_prefix}-sint-probe"
        frontend_port = 22623
        backend_port = 22623
        idle_timeout = 30
        load_distribution = "Default"
        enable_floating_point = false        
    }]

    lb_probes = [{
        name = "${var.name_prefix}-api-internal-probe"
        interval = 5
        no_probes = 2
        port = 6443
        request_path = "/readyz"
        protocol = "Https"
    },
    {
        name = "${var.name_prefix}-sint-probe"
        interval = 5
        no_probes = 2
        port = 22623
        request_path = "/healthz"
        protocol = "Https"
    }]
}

module "public_lb" {
    source = "github.com/cloud-native-toolkit/terraform-azure-lb"

    name_prefix             = "${var.name_prefix}-${var.cluster_id}-public-lb"
    resource_group_name     = module.ocp_resource_group.name
    region                  = var.region
    public                  = true
    lb_sku                  = "Standard"
    public_ip_sku           = "Standard"
    public_ip_allocation    = "Static"
    outbound_rule           = false    
    use_ipv4                = true
    use_ipv6                = false
    dns_label               = "${var.name_prefix}-aro"
    create_fqdn             = true 

    lb_rules = [{
        name = "${var.name_prefix}-api-external-rule"
        protocol = "Tcp"
        probe_name = "${var.name_prefix}-api-external-probe"
        frontend_port = 6443
        backend_port = 6443
        idle_timeout = 30
        load_distribution = "Default"
        enable_floating_point = false 
    }]

    lb_probes = [{
        name = "${var.name_prefix}-api-external-probe"
        interval = 5
        no_probes = 2
        port = 6443
        request_path = "/readyz"
        protocol = "Https"        
    }]
}