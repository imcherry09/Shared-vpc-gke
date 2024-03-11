terraform {
  backend "gcs" {
    bucket  = "tf_states_bucket"
    prefix  = "gke"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "gcs" # or another backend like gcs, etc.
  config = {
    bucket = "tf_states_bucket"
    prefix = "shared-vpc"
  }
}
module "project-svc-gke" {
  source          = "../../../modules/project"
  parent          = data.terraform_remote_state.vpc.outputs.shared_vpc_folder_id
#parent = "folders/${google_folder.shared_vpc_2.id}"
  billing_account = var.billing_account_id
  prefix          = var.prefix
  name            = "svc-project-gke"
  services        = var.project_services
  shared_vpc_service_config = {
   host_project = data.terraform_remote_state.vpc.outputs.host_project_id
    service_identity_iam = {
      "roles/container.hostServiceAgentUser" = ["container-engine"]
      "roles/compute.networkUser"            = ["container-engine"]
      "roles/compute.networkAdmin" = ["cloudservices"]
    }
  }
  iam = merge(
    {
      "roles/container.developer" = [data.terraform_remote_state.vpc.outputs.bastion-service_account_iam_email]
      "roles/owner"               = var.owners_gke
    },
    var.cluster_create
    ? {
      "roles/logging.logWriter"       = [module.cluster-1-nodepool-1.0.service_account_iam_email]
      "roles/monitoring.metricWriter" = [module.cluster-1-nodepool-1.0.service_account_iam_email]
    }
    : {}
  )
}

# module "vpc-shared" {
#   source     = "../../../modules/net-vpc"
#   project_id = data.terraform_remote_state.vpc.outputs.host_project_id
#   name       = "shared-vpc"
#    subnets = [
#     # {
#     #   ip_cidr_range = var.ip_ranges.gce
#     #   name          = "gce"
#     #   region        = var.region
#     #   iam = {
#     #     "roles/compute.networkUser" = concat(var.owners_gce, [
#     #       "serviceAccount:${module.project-svc-gce.service_accounts.cloud_services}",
#     #     ])
#     #   }
#     # },
#     {
#       ip_cidr_range = var.ip_ranges.gke
#       name          = "gke"
#       region        = var.region
#       secondary_ip_ranges = {
#        # pods     = var.ip_secondary_ranges.gke-pods
#         #services = var.ip_secondary_ranges.gke-services
#       }

#       #uncomment for gke
#       iam = {
#         "roles/compute.networkUser" = concat(var.owners_gke, [
#           "serviceAccount:${module.project-svc-gke.service_accounts.cloud_services}",
#           "serviceAccount:${module.project-svc-gke.service_accounts.robots.container-engine}",
#         ])
#         "roles/compute.securityAdmin" = [
#           "serviceAccount:${module.project-svc-gke.service_accounts.robots.container-engine}",
#         ]
#       }
#     }
#   ]
# }


module "cluster-1" {
  source     = "../../../modules/gke-cluster-standard"
  count      = var.cluster_create ? 1 : 0
  name       = "cluster-1"
  project_id = module.project-svc-gke.project_id
  location   = "${var.region}-b"
  vpc_config = {
    #network    = module.vpc-shared.self_link
    network = data.terraform_remote_state.vpc.outputs.vpc_shared_self_link
    subnetwork = data.terraform_remote_state.vpc.outputs.subnet_self_links["gke"]
    #subnetwork = module.vpc-shared.subnet_self_links["${var.region}/gke"]
    #subnetwork = data.terraform_remote_state.vpc.outputs.shared_vpc_subnet_self_links["${var.region}/gke"]
    #Added ranges for pods and services
     secondary_range_names = {
      #pods     = data.terraform_remote_state.vpc.outputs.subnet_secondary_ranges["gke"].pods
      #services = data.terraform_remote_state.vpc.outputs.subnet_secondary_ranges["gke"].services
      #pods     = var.secondary_range_names["pods"]
      #services = var.secondary_range_names["services"]
    }
    # secondary_range_names = {
    #   pods     = var.pods_range_name // The actual name of the secondary range for pods
    #   services = var.services_range_name // The actual name of the secondary range for services
    # }

   
    master_authorized_ranges = {
      internal-vms = var.ip_ranges.gce
    }
    master_ipv4_cidr_block = var.private_service_ranges.cluster-1
    
  }
  max_pods_per_node = 32
  private_cluster_config = {
    enable_private_endpoint = true
    master_global_access    = true
  }
  labels = {
    environment = "test"
  }
  deletion_protection = var.deletion_protection
}

module "cluster-1-nodepool-1" {
  source       = "../../../modules/gke-nodepool"
  count        = var.cluster_create ? 1 : 0
  name         = "nodepool-1"
  project_id   = module.project-svc-gke.project_id
  location     = module.cluster-1.0.location
  cluster_name = module.cluster-1.0.name
  cluster_id   = module.cluster-1.0.id
  service_account = {
    create = true
  }
}



# module "gke_cluster" {
# source     = "../../../modules/gke-cluster-standard"
# project_id = var.project_id
# location   = var.region
# name       = var.cluster_name
#  vpc_config = {
#     network    = var.vpc_network_name  // Ensure this matches the name of your existing VPC
#     subnetwork = var.vpc_subnetwork_name // Ensure this matches the name of your existing subnetwork
#     // Add additional configurations as needed
#   }
#   deletion_protection = var.deletion_protection
# }

# module "gke_node_pool" {
#   source     = "../../../modules/gke-nodepool"
#   project_id = var.project_id
#   location   = var.region
#   cluster_name = var.cluster_name   // Add the cluster_name
#   name       = "my-node-pool"

# #   node_config = {
# #     machine_type = "e2-medium"
# #     disk_size_gb = 100
# #     // Other node configurations...
# #   }

# #   node_count = {
# #     initial = 1
# #    # current = 1
# #   }

#   // Add other node pool configurations as needed.
# }

  // Add other node pool configurations as needed.
