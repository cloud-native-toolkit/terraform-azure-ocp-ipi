output "resource_group_name" {
    value = module.ocp_resource_group.name
    description = "Resource group name containing the OpenShift cluster and other resources created by this automation"
}

output "resource_group_id" {
    value = module.ocp_resource_group.id
    description = "Id of the created resource group to contain the OpenShift cluster"
}

output "network_resource_group_name" {
    value = local.resource_group
    description = "Network resource group name (pass through if using existing, same as OCP if creating one)"
}

output "region" {
    value = var.region
    description = "Pass-through of region containing vnet"
}

output "vnet_name" {
    value = data.azurerm_virtual_network.vnet.name
    description = "Name of the VNet into which to deploy OCP (either created or pass-through)"
}

output "vnet_id" {
    value = data.azurerm_virtual_network.vnet.id
    description = "Id of the Virtual Network"
}

output "master_subnet_id" {
    value = data.azurerm_subnet.master_subnet.id
    description = "Id of the master subnet"
}

output "master_subnet_name" {
    value = data.azurerm_subnet.master_subnet.name
    description = "Name of the master subnet"
}

output "worker_subnet_id" {
    value = data.azurerm_subnet.worker_subnet.id
    description = "Id of the worker subnet"
}

output "worker_subnet_name" {
    value = data.azurerm_subnet.worker_subnet.name
    description = "Name of the worker subnet"
}

output "nsg_id" {
    value = azurerm_network_security_group.cluster.id
    description = "Id of the network security group"
}

output "nsg_name" {
    value = azurerm_network_security_group.cluster.name
    description = "Name of the network security group"
}

output "internal_lb_id" {
    value = module.internal_lb.id
    description = "ID of the internal load balancer"
}

output "internal_lb_backend_pool_id" {
    value = module.internal_lb.backend_pool_id_v4
    description = "ID of the internal load balancer backend pool"
}

output "public_lb_id" {
    value = module.public_lb.id
    description = "ID of the public load balancer"
}

output "public_lb_backend_pool_id" {
    value = module.public_lb.backend_pool_id_v4
    description = "ID of the public load balancer backend pool"
}