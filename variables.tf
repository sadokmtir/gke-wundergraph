
variable "cluster_network_config" {
  description = "Cluster network configuration."
  type = object({
    nodes_cidr_block              = string
    pods_cidr_block               = string
    services_cidr_block           = string
    master_authorized_cidr_blocks = map(string)
    master_cidr_block             = string
  })
  default = {
    nodes_cidr_block    = "10.0.1.0/24"
    pods_cidr_block     = "172.16.0.0/20"
    services_cidr_block = "192.168.0.0/24"
    master_authorized_cidr_blocks = {
      internal = "10.0.0.0/8"
    }
    master_cidr_block = "10.0.0.0/28"
  }
}

variable "deletion_protection" {
  description = "Prevent Terraform from destroying data storage resources (storage buckets, GKE clusters, CloudSQL instances) in this blueprint. When this field is set in Terraform state, a terraform destroy or terraform apply that would delete data storage resources will fail."
  type        = bool
  default     = false
  nullable    = false
}

variable "mgmt_server_config" {
  description = "Management server configuration."
  type = object({
    disk_size     = number
    disk_type     = string
    image         = string
    instance_type = string
  })
  default = {
    disk_size     = 50
    disk_type     = "pd-ssd"
    image         = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
    instance_type = "n1-standard-2"
  }
}

variable "mgmt_subnet_cidr_block" {
  description = "Management subnet IP CIDR range."
  type        = string
  default     = "10.0.2.0/24"
}


variable "project_id" {
  description = "Project ID."
  type        = string
  default     = "gke-autopilot-wunder"
}

variable "region" {
  description = "Region."
  type        = string
  default     = "europe-west1"
}

variable "vpc_create" {
  description = "Flag indicating whether the VPC should be created or not."
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "VPC name."
  type        = string
  nullable    = false
  default     = "wunder-vpc"
}

variable "env" {
  description = "Environment"
  type        = string
  nullable    = false
  default     = "dev"
}
