// ************************************
// Below variables need values provided 

variable "name_prefix" {
  description = "OpenShift Cluster Prefix"
  type        = string
}

variable "domain_resource_group_name" {
  description = "Resource group name containing the base domain name"
  type        = string
}

variable "base_domain" {
    description = "Base domain name (e.g. myclusters.mydomain.com)"
    type        = string
}

variable "region" {
  description = "Azure region into which to deploy"
  type        = string
}

variable "subscription_id" {
  type        = string
  description = "Subscription into which to deploy OpenShift and containing the existing resource group"
}

variable "client_id" {
  type        = string
  description = "The client id (service principal appID) to be used for OpenShift"
}

variable "client_secret" {
  type        = string
  description = "The client secret (e.g. service principal password) to be used for OpenShift"
}

variable "tenant_id" {
  type        = string
  description = "Tenant id containing the subscription"
}

// **********************************
// Following variables have defaults 

variable "pull_secret" {
    description = "Pull secret for OpenShift image repository access and to register the cluster"
    type        = string
    default     = ""
}

variable "pull_secret_file" {
    description = "File with the pull secret for OpenShift image repository access and to register the cluster"
    type        = string
    default     = ""
}

variable "binary_offset" {
    description = "Path offset from current working directory to install binaries (default = binaries)"
    type        = string
    default     = "binaries"
}

variable "install_offset" {
    description = "Path offset from current working directory for install metadata (default = install)"
    type        = string
    default     = "install"
}

variable "openshift_ssh_key" {
  description = "The SSH Public Key to use for OpenShift Installation"
  type        = string
  default     = ""
}

variable "vnet_name" {
    description = "VNet name to deploy into if using existing VNet"
    type        = string
    default     = ""
}

variable "master_subnet_name" {
    description = "Name of the master subnet"
    type        = string
    default     = ""
}

variable "worker_subnet_name" {
    description = "Name of the worker subnet"
    type        = string
    default     = ""
}

variable "openshift_version" {
  description = "OpenShift version to install"
  type        = string
  default     = "4.10.11"
  validation {
    condition = (
        substr(var.openshift_version, 0 , 2) == "4."
    )
    error_message = "Openshift version must be either \"4.x\" or \"4.x.x\"."
  }
}

variable "binary_url_base" {
    description = "Base URL for OpenShift installer and CLI binaries"
    type        = string
    default     = "https://mirror.openshift.com/pub/openshift-v4"
}

variable "network_resource_group_name" {
    description = "Name of the resource group for the network components (must be different to the overall resource group)"
    type        = string
    default     = ""
}

variable "master_hyperthreading" {
    description = "Enable hyperthreading for master nodes (default = enabled)"
    type        = string
    default     = "Enabled"
}

variable "master_architecture" {
    description = "CPU Architecture for the master nodes (default = amd64)"
    type        = string
    default     = "amd64"
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

variable "worker_architecture" {
    description = "CPU Architecture for the worker nodes (default = amd64)"
    type        = string
    default     = "amd64"
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