
// Create network interfaces on subnet
resource "azurerm_network_interface" "master" {
    count = var.node_qty

    name                  = "${var.cluster_infra_name}-master${count.index}-nic"
    location              = var.region
    resource_group_name   = var.resource_group_name

    ip_configuration {
        name                          = "${var.cluster_infra_name}-master${count.index}-nic-ip"
        primary                       = true
        subnet_id                     = var.subnet_id
        private_ip_address_version    = "IPv4"
        private_ip_address_allocation = "Dynamic"
    }
}

// Associated NICs with backend load balancer pools
resource "azurerm_network_interface_backend_address_pool_association" "master_public" {
    count = var.node_qty

    network_interface_id        = element(azurerm_network_interface.master.*.id, count.index)
    backend_address_pool_id     = var.public_lb_pool_id
    ip_configuration_name       = "${var.cluster_infra_name}-master${count.index}-nic-ip"
}

resource "azurerm_network_interface_backend_address_pool_association" "master_internal" {
    count = var.node_qty

    network_interface_id        = element(azurerm_network_interface.master.*.id, count.index)
    backend_address_pool_id     = var.internal_lb_pool_id
    ip_configuration_name       = "${var.cluster_infra_name}-master${count.index}-nic-ip"
}

// Create the master virtual machines
resource "azurerm_linux_virtual_machine" "master" {
    count = var.node_qty

    name = "${var.cluster_infra_name}-master-${count.index}"
    location = var.region
    zone = length(var.availability_zones) > 1 ? var.availability_zones[count.index] : var.availability_zones[0]
    resource_group_name = var.resource_group_name
    network_interface_ids = [element(azurerm_network_interface.master.*.id, count.index)]
    size = var.master_node_type

    source_image_id                 = var.vm_image
    computer_name                   = "${var.cluster_infra_name}-master${count.index}-vm"
    custom_data                     = base64encode(var.ignition)

    // Password is not actually used as the OS will be overwritten
    admin_username                  = "core"
    admin_password                  = "PasswordWillNotBe-This"
    disable_password_authentication = false

    identity {
      type          = "UserAssigned"
      identity_ids  = [var.identity]
    }   

    os_disk {
      name                  = "${var.cluster_infra_name}-master${count.index}_OSDisk"
      caching               = "ReadOnly"
      storage_account_type  = var.storage_type
      disk_size_gb          = var.os_disk_size
    }

    boot_diagnostics {
      storage_account_uri = var.storage_account.primary_blob_endpoint
    }
}