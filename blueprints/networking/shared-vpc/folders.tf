resource "google_folder" "shared_vpc_2" {
  display_name = var.folder_display_name
  parent          = var.root_node
 # parent       = "folders/${var.nbss_main_folder_id}"
}

data "google_folder" "my_folder_info" {
   folder = google_folder.shared_vpc_2.id
}