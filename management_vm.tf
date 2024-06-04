locals {
  zone = "${var.region}-b"
}

module "mgmt_server" {
  source        = "./cloud-foundation-fabric/modules/compute-vm"
  project_id    = module.project.project_id
  zone          = local.zone
  name          = "mgmt"
  instance_type = var.mgmt_server_config.instance_type
  network_interfaces = [{
    network    = module.vpc.self_link
    subnetwork = module.vpc.subnet_self_links["${var.region}/subnet-mgmt"]
    nat        = false
    addresses  = null
  }]
  service_account = {
    auto_create = true
  }
  boot_disk = {
    initialize_params = {
      image = var.mgmt_server_config.image
      type  = var.mgmt_server_config.disk_type
      size  = var.mgmt_server_config.disk_size
    }
  }
  tags = ["ssh"]
}
