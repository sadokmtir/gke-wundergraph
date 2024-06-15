
module "cluster" {
  source     = "./cloud-foundation-fabric/modules/gke-cluster-autopilot"
  project_id = module.project.project_id
  name       = "wundergaph-cluster"
  location   = var.region
  vpc_config = {
    network                  = module.vpc.self_link
    subnetwork               = module.vpc.subnet_self_links["${var.region}/subnet-cluster"]
    secondary_range_names    = {}
    master_authorized_ranges = var.cluster_network_config.master_authorized_cidr_blocks
    master_ipv4_cidr_block   = var.cluster_network_config.master_cidr_block
  }
  enable_features = {
    cost_management          = true
    vertical_pod_autoscaling = true
  }

  private_cluster_config = {
    enable_private_endpoint = true
    master_global_access    = false
  }

  monitoring_config = {
    # (Optional) control plane metrics
    enable_api_server_metrics         = true
    enable_controller_manager_metrics = true
    enable_scheduler_metrics          = true
    # (Optional) kube state metrics
    enable_daemonset_metrics   = true
    enable_deployment_metrics  = true
    enable_hpa_metrics         = true
    enable_pod_metrics         = true
    enable_statefulset_metrics = true
    enable_storage_metrics     = true
  }
  node_config = {
    service_account = module.node_sa.email
  }
  release_channel     = "REGULAR"
  deletion_protection = var.deletion_protection
  depends_on = [
    module.project
  ]
}

module "node_sa" {
  source     = "./cloud-foundation-fabric/modules/iam-service-account"
  project_id = module.project.project_id
  name       = "sa-node"
  iam_project_roles = {
    "${module.project.project_id}" = [
      "roles/artifactregistry.reader",
    ]
  }


}

resource "google_compute_ssl_policy" "gke_ingress_ssl_policy_https" {
  name            = "gke-ingress-ssl-policy-https"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}
