variable "existing_network" {
    description = "Flag to use an existing network"
    type        = bool
    default     = false
}

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

variable "vnet_cidrs" {
    description = "VNet CIDR block"
    type = list(string)
}

variable "region" {
    description = "Azure region into which to deploy resources"
    type        = string
}

// Default values for variables below this

variable "network_resource_group" {
    description = "Resource group name of existing network if using"
    type        = string
    default     = ""
}

variable "existing_vnet_name" {
    description = "Name of the VNet if using existing"
    type        = string
    default     = ""
}

variable "existing_master_subnet_name" {
    description = "Name of the existing master subnet if applicable"
    type        = string
    default     = ""
  
}

variable "existing_worker_subnet_name" {
    description = "Name of the existing worker subnet if applicable"
    type        = string
    default     = ""
  
}
