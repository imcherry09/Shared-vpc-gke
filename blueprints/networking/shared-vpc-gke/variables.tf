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
############################################################################################################
#                           Optional variables for customization : C                                       #
############################################################################################################
variable "cluster_autoscaling" {
  description = "Enable and configure limits for Node Auto-Provisioning with Cluster Autoscaler."
  type = object({
    autoscaling_profile = optional(string, "BALANCED")
    auto_provisioning_defaults = optional(object({
      boot_disk_kms_key = optional(string)
      disk_size         = optional(number)
      disk_type         = optional(string, "pd-standard")
      image_type        = optional(string)
      oauth_scopes      = optional(list(string))
      service_account   = optional(string)
      management = optional(object({
        auto_repair  = optional(bool, true)
        auto_upgrade = optional(bool, true)
      }))
      shielded_instance_config = optional(object({
        integrity_monitoring = optional(bool, true)
        secure_boot          = optional(bool, false)
      }))
      upgrade_settings = optional(object({
        blue_green = optional(object({
          node_pool_soak_duration = optional(string)
          standard_rollout_policy = optional(object({
            batch_percentage    = optional(number)
            batch_node_count    = optional(number)
            batch_soak_duration = optional(string)
          }))
        }))
        surge = optional(object({
          max         = optional(number)
          unavailable = optional(number)
        }))
      }))
      # add validation rule to ensure only one is present if upgrade settings is defined
    }))
    cpu_limits = optional(object({
      min = number
      max = number
    }))
    mem_limits = optional(object({
      min = number
      max = number
    }))
    gpu_resources = optional(list(object({
      resource_type = string
      min           = number
      max           = number
    })))
  })
  default = null
  validation {
    condition = (var.cluster_autoscaling == null ? true : contains(
      ["BALANCED", "OPTIMIZE_UTILIZATION"],
      var.cluster_autoscaling.autoscaling_profile
    ))
    error_message = "Invalid autoscaling_profile."
  }
  validation {
    condition = (
      try(var.cluster_autoscaling, null) == null ||
      try(var.cluster_autoscaling.auto_provisioning_defaults, null) == null ? true : contains(
        ["pd-standard", "pd-ssd", "pd-balanced"],
      var.cluster_autoscaling.auto_provisioning_defaults.disk_type)
    )
    error_message = "Invalid disk_type."
  }
  validation {
    condition = (
      try(var.cluster_autoscaling.upgrade_settings, null) == null || (
        try(var.cluster_autoscaling.upgrade_settings.blue_green, null) == null ? 0 : 1
        +
        try(var.cluster_autoscaling.upgrade_settings.surge, null) == null ? 0 : 1
      ) == 1
    )
    error_message = "Upgrade settings can only use blue/green or surge."
  }
}

# private_cluster_config

variable "private_cluster_config" {
  description = "Private cluster configuration."
  type = object({
    enable_private_endpoint = optional(bool)
    master_global_access    = optional(bool)
    peering_config = optional(object({
      export_routes = optional(bool)
      import_routes = optional(bool)
      project_id    = optional(string)
    }))
  })
  default = null
}

# labels
variable "labels" {
  description = "Cluster resource labels."
  type        = map(string)
  default     = null
}


# node_pools
variable "node_config" {
  description = "Node-level configuration."
  type = object({
    boot_disk_kms_key   = optional(string)
    disk_size_gb        = optional(number)
    disk_type           = optional(string)
    ephemeral_ssd_count = optional(number)
    gcfs                = optional(bool, false)
    guest_accelerator = optional(object({
      count = number
      type  = string
      gpu_driver = optional(object({
        version                    = string
        partition_size             = optional(string)
        max_shared_clients_per_gpu = optional(number)
      }))
    }))
    local_nvme_ssd_count = optional(number)
    gvnic                = optional(bool, false)
    image_type           = optional(string)
    kubelet_config = optional(object({
      cpu_manager_policy   = string
      cpu_cfs_quota        = optional(bool)
      cpu_cfs_quota_period = optional(string)
      pod_pids_limit       = optional(number)
    }))
    linux_node_config = optional(object({
      sysctls     = optional(map(string))
      cgroup_mode = optional(string)
    }))
    local_ssd_count       = optional(number)
    machine_type          = optional(string)
    metadata              = optional(map(string))
    min_cpu_platform      = optional(string)
    preemptible           = optional(bool)
    sandbox_config_gvisor = optional(bool)
    shielded_instance_config = optional(object({
      enable_integrity_monitoring = optional(bool)
      enable_secure_boot          = optional(bool)
    }))
    spot                          = optional(bool)
    workload_metadata_config_mode = optional(string)
  })
  default = {
    disk_type = "pd-balanced"
  }
  validation {
    condition = (
      alltrue([
        for k, v in try(var.node_config.guest_accelerator[0].gpu_driver, {}) : contains([
          "GPU_DRIVER_VERSION_UNSPECIFIED", "INSTALLATION_DISABLED",
          "DEFAULT", "LATEST"
        ], v.version)
      ])
    )
    error_message = "Invalid GPU driver version."
  }
}


variable "node_count" {
  description = "Number of nodes per instance group. Initial value can only be changed by recreation, current is ignored when autoscaling is used."
  type = object({
    current = optional(number)
    initial = number
  })
  default = {
    initial = 1
  }
  nullable = false
}


variable "nodepool_config" {
  description = "Nodepool-level configuration."
  type = object({
    autoscaling = optional(object({
      location_policy = optional(string)
      max_node_count  = optional(number)
      min_node_count  = optional(number)
      use_total_nodes = optional(bool, false)
    }))
    management = optional(object({
      auto_repair  = optional(bool)
      auto_upgrade = optional(bool)
    }))
    # placement_policy = optional(bool)
    upgrade_settings = optional(object({
      max_surge       = number
      max_unavailable = number
    }))
  })
  default = null
}

variable "taints" {
  description = "Kubernetes taints applied to all nodes."
  type = map(object({
    value  = string
    effect = string
  }))
  nullable = false
  default  = {}
  validation {
    condition = alltrue([
      for k, v in var.taints :
      contains(["NO_SCHEDULE", "PREFER_NO_SCHEDULE", "NO_EXECUTE"], v.effect)
    ])
    error_message = "Invalid taint effect."
  }
}

variable "logging_config" {
  description = "Logging configuration."
  type = object({
    enable_system_logs             = optional(bool, true)
    enable_workloads_logs          = optional(bool, false)
    enable_api_server_logs         = optional(bool, false)
    enable_scheduler_logs          = optional(bool, false)
    enable_controller_manager_logs = optional(bool, false)
  })
  default  = {}
  nullable = false
  # System logs are the minimum required component for enabling log collection.
  # So either everything is off (false), or enable_system_logs must be true.
  validation {
    condition = (
      !anytrue(values(var.logging_config)) || var.logging_config.enable_system_logs
    )
    error_message = "System logs are the minimum required component for enabling log collection."
  }
}

variable "maintenance_config" {
  description = "Maintenance window configuration."
  type = object({
    daily_window_start_time = optional(string)
    recurring_window = optional(object({
      start_time = string
      end_time   = string
      recurrence = string
    }))
    maintenance_exclusions = optional(list(object({
      name       = string
      start_time = string
      end_time   = string
      scope      = optional(string)
    })))
  })
  default = {
    daily_window_start_time = "03:00"
    recurring_window        = null
    maintenance_exclusion   = []
  }
}

variable "enable_addons" {
  description = "Addons enabled in the cluster (true means enabled)."
  type = object({
    cloudrun                       = optional(bool, false)
    config_connector               = optional(bool, false)
    dns_cache                      = optional(bool, false)
    gce_persistent_disk_csi_driver = optional(bool, false)
    gcp_filestore_csi_driver       = optional(bool, false)
    gcs_fuse_csi_driver            = optional(bool, false)
    horizontal_pod_autoscaling     = optional(bool, false)
    http_load_balancing            = optional(bool, false)
    istio = optional(object({
      enable_tls = bool
    }))
    kalm           = optional(bool, false)
    network_policy = optional(bool, false)
  })
  default = {
    horizontal_pod_autoscaling = true
    http_load_balancing        = true
  }
  nullable = false
}


variable "enable_features" {
  description = "Enable cluster-level features. Certain features allow configuration."
  type = object({
    beta_apis            = optional(list(string))
    binary_authorization = optional(bool, false)
    cost_management      = optional(bool, false)
    dns = optional(object({
      provider = optional(string)
      scope    = optional(string)
      domain   = optional(string)
    }))
    database_encryption = optional(object({
      state    = string
      key_name = string
    }))
    dataplane_v2         = optional(bool, false)
    fqdn_network_policy  = optional(bool, false)
    gateway_api          = optional(bool, false)
    groups_for_rbac      = optional(string)
    image_streaming      = optional(bool, false)
    intranode_visibility = optional(bool, false)
    l4_ilb_subsetting    = optional(bool, false)
    mesh_certificates    = optional(bool)
    pod_security_policy  = optional(bool, false)
    resource_usage_export = optional(object({
      dataset                              = string
      enable_network_egress_metering       = optional(bool)
      enable_resource_consumption_metering = optional(bool)
    }))
    service_external_ips = optional(bool, true)
    shielded_nodes       = optional(bool, false)
    tpu                  = optional(bool, false)
    upgrade_notifications = optional(object({
      topic_id = optional(string)
    }))
    vertical_pod_autoscaling = optional(bool, false)
    workload_identity        = optional(bool, true)
  })
  default = {
    workload_identity = true
  }
  validation {
    condition = (
      var.enable_features.fqdn_network_policy ? var.enable_features.dataplane_v2 : true
    )
    error_message = "FQDN network policy is only supported for clusters with Dataplane v2."
  }
}

variable "max_pods_per_node" {
  description = "Maximum number of pods per node in this cluster."
  type        = number
  default     = 110
}

#added: C
# variable "nodepool_service_account_email" {
#   description = "The service account email used for the node pool"
#   type        = string
#   default     = null
# }

# variable "autoscaler_service_account_email" {
#   description = "The email of the service account used by the cluster autoscaler"
#   type        = string
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
