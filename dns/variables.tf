variable "cluster_name" {
    description = "The name of the cluster used for domain prefix"
    type        = string
}

variable "base_domain" {
    description = "Base domain of the cluster"
    type        = string
}

variable "domain_resource_group_name" {
    description = "Resource group containing the domain name records"
    type        = string
}

variable "cluster_infra_name" {
    description = "Name of the cluster infrastructure (typicall \"cluster_name-cluster_id\")"
    type = string
}

variable "resource_group_name" {
    description = "Resource group name containing the cluster resources"
    type        = string
}

variable "virtual_network_id" {
    description = "Virtual network ID to use"
    type        = string
}

variable "internal_lb_ip" {
    description = "IP of the internal load balancer"
    type        = string
}

variable "external_lb_fqdn" {
    description = "FQDN of the external IP address of the public load balancer"
    type        = string
}


// Variables below this have default values

variable "ttl" {
    description = "Time to live for the CNAME record"  
    type = number
    default = 300
}