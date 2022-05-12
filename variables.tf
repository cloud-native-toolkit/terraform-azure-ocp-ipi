variable "name_prefix" {
  description = "Prefix to use for all resources"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "resource_group_id" {
  description = "Resource group id"
  type        = string
}

variable "vnet_name" {
    description = "VNet name to deploy into"
    type        = string
}

variable "region" {
  description = "Azure region into which to deploy"
  type        = string
}

variable "master_subnet_name" {
    description = "Name of the master subnet"
    type        = string
}

variable "worker_subnet_name" {
    description = "Name of the worker subnet"
    type        = string
}

variable "openshift_version" {
  description = "OpenShift version to install"
  type        = string
  default     = "4.10.11"
}

variable "subscription_id" {
  type        = string
  description = "the value of subscription_id"
}
variable "client_id" {
  type        = string
  description = "the value of client_id"
}
variable "client_secret" {
  type        = string
  description = "the value of client_secret"
}

variable "tenant_id" {
  type        = string
  description = "the value of tenant_id"
}

variable "pull_secret_file" {
    description = "File with the pull secret for OpenShift image repository access and to register the cluster"
    type        = string
}

variable "openshift_ssh_key" {
  description = "The SSH Public Key to use for OpenShift Installation"
  type        = string
}

variable "install_path" {
    description = "Local filesystem path for the installation binaries and configuration files (default = ./install)"
    type        = string
    default     = "./install"
}

variable "binary_url_base" {
    description = "Base URL for OpenShift installer and CLI binaries"
    type        = string
    default     = "https://mirror.openshift.com/pub/openshift-v4"
}


// Following variables used for install_config.yaml file

variable "base_domain" {
    description = "Public DNS domain name"
    type        = string
}

variable "credentials_mode" {
    description = "Type of Cloud Credential Operator to be utilized (default = Mint)"
    type = string
    default = "Mint"
}

variable "network_resource_group_name" {
    description = "Name of the resource group for the network components (must be different to the overall resource group)"
    type        = string
}

variable "master_hyperthreading" {
    description = "Enable hyperthreading for master nodes (default = enabled)"
    type        = string
    default     = "Enabled"
}

variable "master_node_disk_size" {
    description = "Size of master node disk in GB (default = 120)"
    type        = string
    default     = 120
}

variable "master_node_disk_type" {
    description = "Type of disk for the master nodes (default = Premium_LRS)"
    type        = string
    default     = "Premium_LRS"
}

variable "master_node_type" {
    description = "Master node type (defualt = Standard_D2s_v3)"
    type        = string
    default     = "Standard_D8s_v3"
}

variable "master_node_qty" {
    description = "Number of master nodes to create (default = 3)"
    type        = string
    default     = 3
}

variable "worker_hyperthreading" {
    description = "Enable hyperthreading for compute/worker nodes (default = enabled)"
    type        = string
    default     = "Enabled"
}

variable "worker_node_type" {
    description = "Compute/worker node type (default = Standard_D2s_v3)"
    type        = string
    default     = "Standard_D4s_v3"
}

variable "worker_node_disk_size" {
    description = "Compute/worker node disk size in GB (default = 120)"
    type        = string
    default     = 120
}

variable "worker_node_disk_type" {
    description = "Type of disk for the worker nodes (default = Premium_LRS)"
    type        = string
    default     = "Premium_LRS"
}

variable "worker_node_qty" {
    description = "Number of compute/worker nodes to create (default = 3)"
    type        = string
    default     = 3
}

variable "cluster_cidr" {
    description = "CIDR for the internal OpenShift network (default = 10.128.0.0/14)"
    type        = string
    default     = "10.128.0.0/14"
}

variable "cluster_host_prefix" {
    description = "Host prefix for internal OpenShift network (default = 23)"
    type        = string
    default     = 23
}

variable "machine_cidr" {
    description = "CIDR for master and compute nodes (default = 10.0.0.0/16)"
    type = string
    default = "10.0.0.0/16"
}

variable "network_type" {
    description = "Network plugin to use (default = OpenShiftSDN)"
    type = string
    default = "OpenShiftSDN"
}

variable "service_network_cidr" {
    description = "CIDR for the internal OpenShift service network (default = 172.30.0.0/16)"
    type        = string
    default     = "172.30.0.0/16"
}

variable "outbound_type" {
    description = "The type of outbound routing to use. Loadbalancer (default) or UserDefinedRouting"
    type        = string
    default     = "Loadbalancer"
}

variable "enable_fips" {
    description = "Enable FIPS in the cluster (default = false)"
    type        = string
    default     = false
}