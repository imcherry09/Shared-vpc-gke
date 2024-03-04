


# locals {
#   folder_id = split("/", data.terraform_remote_state.shared_vpc.outputs.shared_vpc_folder_id)[1]
# }

###############################################################################
#                                   project                                   #
###############################################################################
module "project" {
  source          = "../../../modules/project"
 parent          = data.terraform_remote_state.shared_vpc.outputs.shared_vpc_folder_id #added from shared vpc folder
  #parent = local.folder_id
 #parent = "folders/${google_folder.shared_vpc_2.id}"
  #billing_account = var.billing_account_id
  prefix          = var.prefix
  name            = "hub-project"
  compute_metadata = var.project_create.oslogin != true ? {} : {
    enable-oslogin = "true"
  }
  services = [
    "compute.googleapis.com",
    "container.googleapis.com"
  ]
}
################################################################################
#                                Hub networking                                #
################################################################################
module "vpc-hub" {
source  = "../../../modules/net-vpc"
  project_id = module.project.project_id
  name       = "${var.prefix}-hub"
  subnets = [
    {
      ip_cidr_range = var.ip_ranges.hub
      name          = "${var.prefix}-hub-1"
      region        = var.region
    }
  ]
}

module "nat-hub" {
  source         = "../../../modules/net-cloudnat"
  project_id     = module.project.project_id
  region         = var.region
  name           = "${var.prefix}-hub"
  router_name    = "${var.prefix}-hub"
  router_network = module.vpc-hub.self_link
}

module "vpc-hub-firewall" {
  source     = "../../../modules/net-vpc-firewall"
  project_id = module.project.project_id
  network    = module.vpc-hub.name
  default_rules_config = {
    admin_ranges = values(var.ip_ranges)
  }
}

# Peering to shared VPC
data "terraform_remote_state" "shared_vpc" {
  backend = "gcs"
  config = {
    bucket = "terraform_state_files_bucket"
    prefix = "shared-vpc"
  }
}

module "hub-to-spoke-1-peering" {
  source        = "../../../modules/net-vpc-peering"
  local_network = module.vpc-hub.self_link
  peer_network  = data.terraform_remote_state.shared_vpc.outputs.shared_vpc_self_link
  routes_config = {
    local = { export = true, import = false }
    peer  = { export = false, import = true }
  }
}
# resource "google_compute_network_peering" "hub_to_shared" {
#   name         = "hub-to-shared-peering"
#   network      = google_compute_network.hub_vpc.self_link  # Assuming this is defined earlier in the same configuration
#   peer_network = data.terraform_remote_state.shared_vpc.outputs.shared_vpc_self_link
# }