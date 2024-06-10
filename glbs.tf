locals {
  urls = { for k, v in module.addresses.global_addresses : k => "${v.address}" }
}

module "addresses" {
  source     = "./cloud-foundation-fabric/modules/net-address"
  project_id = module.project.project_id
  global_addresses = {
    app = {}
  }
}
