# Resource Group Variables

variable "region" {
  type        = string
  description = "Region/location to deploy into."
}

variable "subscription_id" {}

variable "client_id" {}

variable "client_secret" {}

variable "tenant_id" {}

variable "pull_secret" {}