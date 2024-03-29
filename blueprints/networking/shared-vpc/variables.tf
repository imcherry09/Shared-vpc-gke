# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

variable "billing_account_id" {
  description = "Billing account id used as default for new projects."
  type        = string
}

variable "cluster_create" {
  description = "Create GKE cluster and nodepool."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Prevent Terraform from destroying data storage resources (storage buckets, GKE clusters, CloudSQL instances) in this blueprint. When this field is set in Terraform state, a terraform destroy or terraform apply that would delete data storage resources will fail."
  type        = bool
  default     = false
  nullable    = false
}

variable "ip_ranges" {
  description = "Subnet IP CIDR ranges."
  type        = map(string)
  default = {
    gce = "10.0.16.0/24"
    gke = "10.0.32.0/24"
  }
}

variable "ip_secondary_ranges" {
  description = "Secondary IP CIDR ranges."
  type        = map(string)
  default = {
    gke-pods     = "10.128.0.0/18"
    gke-services = "172.16.0.0/24"
  }
}

variable "owners_gce" {
  description = "GCE project owners, in IAM format."
  type        = list(string)
  default     = []
}

variable "owners_gke" {
  description = "GKE project owners, in IAM format."
  type        = list(string)
  default     = []
}

variable "owners_host" {
  description = "Host project owners, in IAM format."
  type        = list(string)
  default     = []
}

variable "prefix" {
  description = "Prefix used for resource names."
  type        = string
  validation {
    condition     = var.prefix != ""
    error_message = "Prefix cannot be empty."
  }
}

variable "private_service_ranges" {
  description = "Private service IP CIDR ranges."
  type        = map(string)
  default = {
    cluster-1 = "192.168.0.0/28"
  }
}

variable "project_services" {
  description = "Service APIs enabled by default in new projects."
  type        = list(string)
  default = [
    "container.googleapis.com",
    "stackdriver.googleapis.com",
  ]
}

variable "region" {
  description = "Region used."
  type        = string
  default     = "europe-west1"
}

variable "root_node" {
  description = "Hierarchy node where projects will be created, 'organizations/org_id' or 'folders/folder_id'."
  type        = string
}


#Own code
variable "folder_display_name" {
  type        = string
  description = "The display name of the folder."
}

variable "secondary_range_names" {
  description = "Names of the secondary IP ranges."
  type = map(string)
  default = {
    pods     = "pods"
    services = "services"
  }
}

# variable "organization" {
#   description = "organization in organization/organization_id format."
# }

# variable "nbss_main_folder_id" {
#   description = "The resource ID of the nbss-main folder"
#   type        = string
# }

# variable "pods_range_name" {
#   description = "Name for the pods range"
#   type        = string
#   default     = "pods" # You can set a default value or omit this line
# }

# variable "services_range_name" {
#   description = "Name for the services range"
#   type        = string
#   default     = "services" # You can set a default value or omit this line
# }

#Variables for GKE-nodepool
# variable "node_config" {
#   description = "Node-level configuration."
#   type = object({
#     boot_disk_kms_key   = optional(string)
#     disk_size_gb        = optional(number)
#     disk_type           = optional(string)
#     ephemeral_ssd_count = optional(number)
#     gcfs                = optional(bool, false)
#     guest_accelerator = optional(object({
#       count = number
#       type  = string
#       gpu_driver = optional(object({
#         version                    = string
#         partition_size             = optional(string)
#         max_shared_clients_per_gpu = optional(number)
#       }))
#     }))
#     local_nvme_ssd_count = optional(number)
#     gvnic                = optional(bool, false)
#     image_type           = optional(string)
#     kubelet_config = optional(object({
#       cpu_manager_policy   = string
#       cpu_cfs_quota        = optional(bool)
#       cpu_cfs_quota_period = optional(string)
#       pod_pids_limit       = optional(number)
#     }))
#     linux_node_config = optional(object({
#       sysctls     = optional(map(string))
#       cgroup_mode = optional(string)
#     }))
#     local_ssd_count       = optional(number)
#     machine_type          = optional(string)
#     metadata              = optional(map(string))
#     min_cpu_platform      = optional(string)
#     preemptible           = optional(bool)
#     sandbox_config_gvisor = optional(bool)
#     shielded_instance_config = optional(object({
#       enable_integrity_monitoring = optional(bool)
#       enable_secure_boot          = optional(bool)
#     }))
#     spot                          = optional(bool)
#     workload_metadata_config_mode = optional(string)
#   })
#   default = {
#     disk_type = "pd-balanced"
#   }
#   validation {
#     condition = (
#       alltrue([
#         for k, v in try(var.node_config.guest_accelerator[0].gpu_driver, {}) : contains([
#           "GPU_DRIVER_VERSION_UNSPECIFIED", "INSTALLATION_DISABLED",
#           "DEFAULT", "LATEST"
#         ], v.version)
#       ])
#     )
#     error_message = "Invalid GPU driver version."
#   }
# }

# variable "min_node_count" {
#   description = "Minimum number of nodes in each node pool."
#   type        = number
#   default     = 1
# }

# variable "max_node_count" {
#   description = "Maximum number of nodes in each node pool."
#   type        = number
#   default     = 3
# }

# variable "auto_repair" {
#   description = "Determines whether nodes are automatically repaired."
#   type        = bool
#   default     = true
# }

# variable "auto_upgrade" {
#   description = "Determines whether nodes are automatically upgraded."
#   type        = bool
#   default     = true
# }
