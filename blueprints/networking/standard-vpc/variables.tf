# variable "project_id" {
#   description = "The project ID to host the network in"
#   type        = string
# }

variable "region" {
  description = "The region where the network will be created"
  type        = string
  default     = "us-central1"
}

variable "vpc_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "my-standard-vpc"
}

variable "subnets" {
  description = "List of subnets to be created in the VPC"
  type = list(object({
    name           = string
    ip_cidr_range  = string
    region         = string
  }))
  default = []
}

variable "routes" {
  description = "Custom routes for the VPC network"
  type        = list(object({
    name                = string
    description         = string
    dest_range          = string
    next_hop_internet   = bool
    next_hop_instance   = string
    next_hop_ip         = string
    next_hop_vpn_tunnel = string
    priority            = number
    tags                = list(string)
  }))
  default     = []
}


variable "billing_account_id" {
  description = "Billing account id used as default for new projects."
  type        = string
}

variable "prefix" {
  description = "Prefix used for resource names."
  type        = string
  validation {
    condition     = var.prefix != ""
    error_message = "Prefix cannot be empty."
  }
}

variable "project_create" {
  description = "Set to non null if project needs to be created."
  type = object({
    billing_account = string
    oslogin         = bool
    parent          = string
  })
  default = null
  validation {
    condition = (
      var.project_create == null
      ? true
      : can(regex("(organizations|folders)/[0-9]+", var.project_create.parent))
    )
    error_message = "Project parent must be of the form folders/folder_id or organizations/organization_id."
  }
}

variable "ip_ranges" {
  description = "IP CIDR ranges."
  type        = map(string)
  default = {
    hub     = "10.0.0.0/24"
    spoke-1 = "10.0.16.0/24"
    spoke-2 = "10.0.32.0/24"
  }
}