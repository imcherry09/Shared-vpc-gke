terraform {
  backend "gcs" {
    bucket  = "tf_states_bucket"
    prefix  = "gke"
  }
}

data "terraform_remote_state" "vpc" {
  count  = var.is_network_created_by_terraform ? 1 : 0
  backend = "gcs"
  config = {
    bucket = "tf_states_bucket"
    prefix = "shared-vpc"
  }
}

module "project-svc-gke" {
  source          = "../../../modules/project"
  parent          = var.is_network_created_by_terraform ? data.terraform_remote_state.vpc.outputs.shared_vpc_folder_id : "specify-parent-folder-id"
  billing_account = var.billing_account_id
  prefix          = var.prefix
  name            = "svc-project-gke"
  services        = var.project_services
  shared_vpc_service_config = {
    host_project = var.is_network_created_by_terraform ? data.terraform_remote_state.vpc.outputs.host_project_id : "specify-host-project-id"
    service_identity_iam = {
      "roles/container.hostServiceAgentUser" = ["container-engine"]
      "roles/compute.networkUser"            = ["container-engine"]
      "roles/compute.networkAdmin"           = ["cloudservices"]
    }
  }
  iam = merge(
    {
      "roles/container.developer" = [var.is_network_created_by_terraform ? data.terraform_remote_state.vpc.outputs.bastion-service_account_iam_email : "specify-bastion-service-account-email"]
      "roles/owner"               = var.owners_gke
    },
    var.cluster_create ? {
      "roles/logging.logWriter"       = [module.cluster-1-nodepool-1.count > 0 ? module.cluster-1-nodepool-1[0].service_account_iam_email : ""]
      "roles/monitoring.metricWriter" = [module.cluster-1-nodepool-1.count > 0 ? module.cluster-1-nodepool-1[0].service_account_iam_email : ""]
    } : {}
  )
}

locals {
  gce_subnet_ip_range = var.is_network_created_by_terraform ? data.terraform_remote_state.vpc.outputs.subnet_ips["gce"] : var.manual_gce_subnet_ip_range
}

module "cluster-1" {
  source     = "../../../modules/gke-cluster-standard"
  count      = var.cluster_create ? 1 : 0
  name       = "cluster-1"
  project_id = module.project-svc-gke.project_id
  location   = "${var.region}-b"
  vpc_config = {
    network    = var.is_network_created_by_terraform ? data.terraform_remote_state.vpc.outputs.vpc_shared_self_link : var.network_name
    subnetwork = var.is_network_created_by_terraform ? data.terraform_remote_state.vpc.outputs.subnet_self_links["gke"] : var.subnetwork_name
    secondary_range_names = {
      pods     = var.ip_secondary_ranges["gke-pods"]
      services = var.ip_secondary_ranges["gke-services"]
    }
    master_authorized_ranges = {
      internal-vms = local.gce_subnet_ip_range
    }
    master_ipv4_cidr_block = var.private_service_ranges["cluster-1"]
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



