variable "region" {
  description = "The region for the GKE cluster."
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network for the GKE cluster."
  type        = string
}

variable "subnetwork_name" {
  description = "The name of the subnetwork in the VPC."
  type        = string
}

variable "is_network_created_by_terraform" {
  description = "Set to true if the network is created by Terraform."
  type        = bool
}

variable "cluster_name" {
  description = "Name of the GKE cluster."
  type        = string
}

variable "cluster_create" {
  description = "Create GKE cluster and nodepool."
  type        = bool
  default     = false
}

variable "billing_account_id" {
  description = "Billing account id used as default for new projects."
  type        = string
}

variable "prefix" {
  description = "Prefix used for resource names."
  type        = string
}

variable "project_services" {
  description = "Service APIs enabled by default in new projects."
  type        = list(string)
  default     = [
    "container.googleapis.com",
    "stackdriver.googleapis.com",
  ]
}

variable "private_service_ranges" {
  description = "Private service IP CIDR ranges."
  type        = map(string)
  default     = {
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
  default     = {
    gke-pods     = "10.128.0.0/18"
    gke-services = "172.16.0.0/24"
  }
}

variable "manual_gce_subnet_ip_range" {
  description = "The IP range of the gce subnet, to be used if the network is created manually."
  type        = string
  default     = "10.0.16.0/24" # Replace with the actual IP range if known
}
