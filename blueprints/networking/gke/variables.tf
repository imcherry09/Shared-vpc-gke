# variable "project_id" {
#   description = "The GCP project ID."
#   type        = string
# }

variable "region" {
  description = "The region for the GKE cluster."
  type        = string
}

variable "ip_ranges" {
  description = "Subnet IP CIDR ranges."
  type        = map(string)
  default = {
    gce = "10.0.16.0/24"
    gke = "10.0.32.0/24"
  }
}

variable "cluster_name" {
  description = "Name of the GKE cluster."
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
# variable "vpc_network_name" {
#   description = "The name of the existing VPC network."
#   type        = string
# }

# variable "vpc_subnetwork_name" {
#   description = "The name of the existing subnetwork in the VPC."
#   type        = string
# }

variable "deletion_protection" {
  description = "Prevent Terraform from destroying data storage resources (storage buckets, GKE clusters, CloudSQL instances) in this blueprint. When this field is set in Terraform state, a terraform destroy or terraform apply that would delete data storage resources will fail."
  type        = bool
  default     = false
  nullable    = false
}

variable "cluster_create" {
  description = "Create GKE cluster and nodepool."
  type        = bool
  default     = false
}

# variable "root_node" {
#   description = "Hierarchy node where projects will be created, 'organizations/org_id' or 'folders/folder_id'."
#   type        = string
# }

variable "project_services" {
  description = "Service APIs enabled by default in new projects."
  type        = list(string)
  default = [
    "container.googleapis.com",
    "stackdriver.googleapis.com",
  ]
}

variable "billing_account_id" {
  description = "Billing account id used as default for new projects."
  type        = string
}

variable "private_service_ranges" {
  description = "Private service IP CIDR ranges."
  type        = map(string)
  default = {
    cluster-1 = "192.168.0.0/28"
  }
}

variable "owners_gke" {
  description = "GKE project owners, in IAM format."
  type        = list(string)
  default     = []
}

variable "ip_secondary_ranges" {
  description = "Secondary IP CIDR ranges."
  type        = map(string)
  default = {
    gke-pods     = "10.128.0.0/18"
    gke-services = "172.16.0.0/24"
  }
}