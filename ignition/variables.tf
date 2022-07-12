variable "name_prefix" {
  description = "Prefix to be given to resource names"
  type        = string  
}

variable "cluster_name" {
  description = "Name for the OpenShift cluster (also used as subdomain prefix)"
  type        = string
}

variable "cluster_infra_name" {
  description = "Name of the cluster infrastructure (typicall \"cluster_name-cluster_id\")"
  type = string
}

variable "cluster_id" {
  description = "5 digit random number for the cluster ID"
  type        = string
  validation {
    condition     = length(var.cluster_id) == 5
    error_message = "The cluster_id must be 5 random digits"
  }
}

variable "bin_dir" {
  description = "Location of binary files for installation, will be created if it does not exist"
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

variable "network_resource_group_name" {
  description = "Name of the resource group containing the network resources"
  type        = string
}

variable "domain_resource_group_name" {
  description = "Name of the resource group containing the DNS zone resources"
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "master_subnet_name" {
  description = "Name of the master / control subnet"
  type        = string
}

variable "worker_subnet_name" {
  description = "Name of the worker / compute subnet"
  type        = string
}

variable "nsg_name" {
  description = "Name of the network security group for the cluster"
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

variable "base_domain" {
  description = "Base domain name (e.g. myclusters.mydomain.com)"
  type        = string
}

variable "pull_secret" {
  description = "Pull secret for OpenShift image repository access and to register the cluster"
  type        = string
}

variable "install_path" {
  description = "Path to the installer directory"
  type = string
}

variable "availability_zones" {
  description = "Availability zones to deploy master nodes into. Either [1] or [1, 2, 2]"
  type        = list(string)
}

variable "public_ssh_key" {
  description = "Public SSH key for node access"
  type        = string
}

// Below variables have default values

variable "storage_account_tier" {
  description = "Storage account tier to be utilised - Standard (default) or Premium"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "Storage account replication type to be utilised - LRS (default), GRS, RAGRS, ZRS, GZRS or RAGZRS"
  type        = string
  default     = "LRS"
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
  description = "Master node type (default = Standard_D8s_v3)"
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


