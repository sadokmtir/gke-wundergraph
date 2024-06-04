
module "vpc" {
  source     = "./cloud-foundation-fabric/modules/net-vpc"
  project_id = module.project.project_id
  name       = var.vpc_name
  vpc_create = var.vpc_create
  subnets = [
    {
      ip_cidr_range = var.mgmt_subnet_cidr_block
      name          = "subnet-mgmt"
      region        = var.region
    },
    {
      ip_cidr_range = var.cluster_network_config.nodes_cidr_block
      name          = "subnet-cluster"
      region        = var.region
      secondary_ip_ranges = {
        pods     = var.cluster_network_config.pods_cidr_block
        services = var.cluster_network_config.services_cidr_block
      }
    }
  ]
}

# enabling SSH to private addresses from IAP, and HTTP/HTTPS from the health checkers
module "firewall" {
  source     = "./cloud-foundation-fabric/modules/net-vpc-firewall"
  project_id = module.project.project_id
  network    = module.vpc.name
}

# creates nat for all ranges for all subnets 
module "nat" {
  source         = "./cloud-foundation-fabric/modules/net-cloudnat"
  project_id     = module.project.project_id
  region         = var.region
  name           = "nat"
  router_network = module.vpc.name
}
