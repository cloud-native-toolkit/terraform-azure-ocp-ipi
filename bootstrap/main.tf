

resource "azurerm_public_ip" "bootstrap_public_ip" {
    name                = "${var.name_prefix}-${var.cluster_id}-bootstrap-pip"
    location            = var.region
    resource_group_name = var.resource_group_name
    sku                 = "Standard"
    allocation_method   = "Static"
}

data "azurerm_public_ip" "bootstrap_public_ip" {
    name                = azurerm_public_ip.bootstrap_public_ip.name
    resource_group_name = var.resource_group_name
}

resource "azurerm_network_interface" "bootstrap" {
    name                = "${var.name_prefix}-${var.cluster_id}-bootstrap-nic"
    location            = var.region
    resource_group_name = var.resource_group_name

    ip_configuration {
      name                          = "${var.name_prefix}-${var.cluster_id}-nic-ip"
      subnet_id                     = var.subnet_id
      private_ip_address_version    = "IPv4"
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.bootstrap_public_ip.id
    }
}

resource "azurerm_linux_virtual_machine" "bootstrap" {
    name                            = "${var.name_prefix}-${var.cluster_id}-bootstrap"
    location                        = var.region
    resource_group_name             = var.resource_group_name
    network_interface_ids           = [azurerm_network_interface.bootstrap.id]
    size                            = var.vm_size
    source_image_id                 = var.vm_image
    computer_name                   = "${var.name_prefix}-${var.cluster_id}-bootstrap-vm"
    #custom_data                     = base64encode(var.ignition)

    // Password is not actually used as the OS will be overwritten
    admin_username                  = "core"
    admin_password                  = "PasswordWillNotBe-This"
    disable_password_authentication = false

    identity {
      type          = "UserAssigned"
      identity_ids  = [var.identity]
    }   

    os_disk {
      name                  = "${var.name_prefix}-${var.cluster_id}-bootstrap_OSDisk"
      caching               = "ReadWrite"
      storage_account_type  = var.storage_type
      disk_size_gb          = var.os_disk_size
    }

    boot_diagnostics {
      storage_account_uri = var.storage_account.primary_blob_endpoint
    }

}

resource "azurerm_network_security_rule" "bootstrap_ssh_in" {
  name                        = "bootstrap_ssh_in"
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.nsg_name
}


// Add backend address pool association for load balancers