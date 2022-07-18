
variable "node_qty" {
    description = "Number of master nodes to create"
    type = number
}

variable "cluster_infra_name" {
    description = "Name of the cluster infrastructure (typicall \"cluster_name-cluster_id\")"
    type = string
}

variable "resource_group_name" {
    description = "Name of the resource group to contain the ignition resources"
    type        = string
}

variable "region" {
    description = "Azure region into which to deploy resources"
    type        = string
}

variable "subnet_id" {
    description = "ID of the subnet to which to attach the bootstrap VM"
    type        = string
}

variable "public_lb_pool_id" {
    description = "ID of the public load balancer backend pool"
    type = string
}

variable "internal_lb_pool_id" {
    description = "ID of the internal load balancer backend pool"
    type = string
}

variable "availability_zones" {
  description = "Availability zones to deploy master nodes into. Either [1] or [1, 2, 2]"
  type        = list(string)
}

variable "master_node_type" {
  description = "Master node type"
  type        = string
}

variable "ignition" {
  type        = string
  description = "The content of the master ignition file."
}

variable "vm_image" {
    description = "Id of the VM image to be utilised"
    type        = string
}

variable "identity" {
    description = "User assigned identity ID for the master VMs"
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