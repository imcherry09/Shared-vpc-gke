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

# output "gke_clusters" {
#   description = "GKE clusters information."
#   value = (
#     var.cluster_create
#     ? { cluster-1 = module.cluster-1.0.endpoint }
#     : {}
#   )
# }

output "host_project_id" {
  value       = module.project-host.project_id
  description = "The project ID of the host project"
}

output "vms" {
  description = "GCE VMs."
  value = {
    (module.vm-bastion.instance.name) = module.vm-bastion.internal_ip
  }
   sensitive = true
}

output "vpc" {
  description = "Shared VPC."
  value = {
    name    = module.vpc-shared.name
    subnets = module.vpc-shared.subnet_ips
  }
}


#Adding folder output which is used for hub vpc 
output "shared_vpc_folder_id" {
  value = google_folder.shared_vpc_2.id
  description = "The ID of the folder created for the Shared VPC"
}

# Adding output for shared vpc self link
# output "shared_vpc_self_link" {
#   value = google_compute_network.network.self_link
#   description = "The self-link of the Shared VPC"
# }

# output "shared_vpc_self_link" {
#   value = module.vpc-shared.self_link
#   description = "The self-link of the Shared VPC"
# }

# output "shared_vpc_subnet_self_links" {
#   value = module.vpc-shared.subnet_self_links
#   description = "The self-links of the subnets in the Shared VPC"
# }

# output "shared_vpc_host_folder_id" {
#   value = google_folder.project_folder.id
#   description = "The ID of the folder for the host project of the Shared VPC"
# }

# output "shared_vpc_2_folder_id" {
#   value       = google_folder.shared_vpc_2.id
#   description = "The ID of the Shared VPC folder."
# }

# output "ip_ranges" {
#   description = "IP ranges."
#   value = {
#     host        = module.vpc-shared.host_ip_range
#     service-gce = module.vpc-shared.service_gce_ip_range
#     #service-gke = module.vpc-shared.service_gke_ip_range
#   }
# }

output "bastion-service_account_iam_email" {
  description = "Bastion service account email."
  value = module.vm-bastion.service_account_iam_email
  
}


# output "subnet_ips" {
#   description = "Map of subnet address ranges keyed by name."
#   value       = module.vpc-shared.subnet_ips
# }

# output "subnet_self_links" {
#   description = "Map of subnet self links keyed by name."
#   value       = module.vpc-shared.subnet_self_links
# }

output "subnet_ips" {
  description = "Map of subnet address ranges keyed by name."
  value       = { for subnet in module.vpc-shared.subnets : subnet.name => subnet.ip_cidr_range }
}

output "subnet_self_links" {
  description = "Map of subnet self links keyed by name."
  value       = { for subnet in module.vpc-shared.subnets : subnet.name => subnet.self_link }
}
# output "subnet_secondary_ranges" {
#   value = { for subnet in module.vpc-shared.subnets : subnet.name => subnet.secondary_ip_ranges }
# }


output "vpc_shared_self_link" {
  description = "The self-link of the Shared VPC."
  value       = module.vpc-shared.self_link
}

output "gce_service_account" {
  description = "The service account for GCE"
  value       = module.project-svc-gce.service_accounts.cloud_services
}

# output "gke_service_account_cloud_services" {
#   description = "The service account for GKE cloud services"
#   value       = module.project-svc-gke.service_accounts.cloud_services
# }

# output "gke_service_account_robots" {
#   description = "The service account for GKE robots"
#   value       = module.project-svc-gke.service_accounts.robots.container-engine
# }