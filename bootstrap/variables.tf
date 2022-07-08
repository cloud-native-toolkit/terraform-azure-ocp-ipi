variable "name_prefix" {
    description = "Prefix to be given to resource names"
    type        = string  
}

variable "cluster_id" {
    description = "5 digit random number for the cluster id"
    type        = string
    validation {
      condition     = length(var.cluster_id) == 5
      error_message = "The cluster_id must be 5 random digits"
    }
}

variable "region" {
    description = "Azure region into which to deploy resources"
    type        = string
}

variable "resource_group_name" {
    description = "Resource group to be used"
    type        = string
}

variable "subnet_id" {
    description = "Id of the subnet to which to attach the bootstrap VM"
    type        = string
}

variable "nsg_name" {
    description = "Name of the network security group to update with bootstrap details"
    type        = string
}

variable "vm_size" {
    description = "Size / SKU ID of the bootstrap VM"
    type        = string
}

variable "vm_image" {
    description = "Id of the VM image to be utilised"
    type        = string
}

variable "identity" {
    description = "User assigned identity id for the bootstrap VM"
    type        = string
}

variable "storage_account" {
    description = "Storage account used for boot diagnostics"
    type = any
}

// Variables below this have default values

variable "storage_type" {
    description = "Type of storage to be utilised (default = Premium_LRS)"
    type        = string
    default     = "Premium_LRS"
}

variable "os_disk_size" {
    description = "Size of the OS disk for the bootstrap server (default = 100GB)"
    type        = number
    default     = 100
}