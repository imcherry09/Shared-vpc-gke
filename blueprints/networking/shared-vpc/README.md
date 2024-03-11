## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.16.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cluster-1"></a> [cluster-1](#module\_cluster-1) | ../../../modules/gke-cluster-standard | n/a |
| <a name="module_cluster-1-nodepool-1"></a> [cluster-1-nodepool-1](#module\_cluster-1-nodepool-1) | ../../../modules/gke-nodepool | n/a |
| <a name="module_host-dns"></a> [host-dns](#module\_host-dns) | ../../../modules/dns | n/a |
| <a name="module_nat"></a> [nat](#module\_nat) | ../../../modules/net-cloudnat | n/a |
| <a name="module_project-host"></a> [project-host](#module\_project-host) | ../../../modules/project | n/a |
| <a name="module_project-svc-gce"></a> [project-svc-gce](#module\_project-svc-gce) | ../../../modules/project | n/a |
| <a name="module_project-svc-gke"></a> [project-svc-gke](#module\_project-svc-gke) | ../../../modules/project | n/a |
| <a name="module_vm-bastion"></a> [vm-bastion](#module\_vm-bastion) | ../../../modules/compute-vm | n/a |
| <a name="module_vpc-shared"></a> [vpc-shared](#module\_vpc-shared) | ../../../modules/net-vpc | n/a |
| <a name="module_vpc-shared-firewall"></a> [vpc-shared-firewall](#module\_vpc-shared-firewall) | ../../../modules/net-vpc-firewall | n/a |

## Resources

| Name | Type |
|------|------|
| [google_folder.shared_vpc_2](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_account_id"></a> [billing\_account\_id](#input\_billing\_account\_id) | Billing account id used as default for new projects. | `string` | n/a | yes |
| <a name="input_cluster_create"></a> [cluster\_create](#input\_cluster\_create) | Create GKE cluster and nodepool. | `bool` | `false` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Prevent Terraform from destroying data storage resources (storage buckets, GKE clusters, CloudSQL instances) in this blueprint. When this field is set in Terraform state, a terraform destroy or terraform apply that would delete data storage resources will fail. | `bool` | `false` | no |
| <a name="input_folder_display_name"></a> [folder\_display\_name](#input\_folder\_display\_name) | The display name of the folder. | `string` | n/a | yes |
| <a name="input_ip_ranges"></a> [ip\_ranges](#input\_ip\_ranges) | Subnet IP CIDR ranges. | `map(string)` | <pre>{<br>  "gce": "10.0.16.0/24",<br>  "gke": "10.0.32.0/24"<br>}</pre> | no |
| <a name="input_ip_secondary_ranges"></a> [ip\_secondary\_ranges](#input\_ip\_secondary\_ranges) | Secondary IP CIDR ranges. | `map(string)` | <pre>{<br>  "gke-pods": "10.128.0.0/18",<br>  "gke-services": "172.16.0.0/24"<br>}</pre> | no |
| <a name="input_owners_gce"></a> [owners\_gce](#input\_owners\_gce) | GCE project owners, in IAM format. | `list(string)` | `[]` | no |
| <a name="input_owners_gke"></a> [owners\_gke](#input\_owners\_gke) | GKE project owners, in IAM format. | `list(string)` | `[]` | no |
| <a name="input_owners_host"></a> [owners\_host](#input\_owners\_host) | Host project owners, in IAM format. | `list(string)` | `[]` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix used for resource names. | `string` | n/a | yes |
| <a name="input_private_service_ranges"></a> [private\_service\_ranges](#input\_private\_service\_ranges) | Private service IP CIDR ranges. | `map(string)` | <pre>{<br>  "cluster-1": "192.168.0.0/28"<br>}</pre> | no |
| <a name="input_project_services"></a> [project\_services](#input\_project\_services) | Service APIs enabled by default in new projects. | `list(string)` | <pre>[<br>  "container.googleapis.com",<br>  "stackdriver.googleapis.com"<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | Region used. | `string` | `"europe-west1"` | no |
| <a name="input_root_node"></a> [root\_node](#input\_root\_node) | Hierarchy node where projects will be created, 'organizations/org\_id' or 'folders/folder\_id'. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gke_clusters"></a> [gke\_clusters](#output\_gke\_clusters) | GKE clusters information. |
| <a name="output_projects"></a> [projects](#output\_projects) | Project ids. |
| <a name="output_vms"></a> [vms](#output\_vms) | GCE VMs. |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | Shared VPC. |
