
module "project" {
  source = "./cloud-foundation-fabric/modules/project"
  parent = null

  project_create = false
  name           = var.project_id
  services = [
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com"
  ]
  iam = {
    "roles/monitoring.viewer"            = [module.monitoring_sa.iam_email]
    "roles/container.nodeServiceAccount" = [module.node_sa.iam_email]
    "roles/container.admin"              = [module.mgmt_server.service_account_iam_email]
    "roles/storage.admin"                = [module.mgmt_server.service_account_iam_email]
    "roles/cloudbuild.builds.editor"     = [module.mgmt_server.service_account_iam_email]
    "roles/viewer"                       = [module.mgmt_server.service_account_iam_email]
  }
  labels = {
    env = var.env
  }

}

module "monitoring_sa" {
  source     = "./cloud-foundation-fabric/modules/iam-service-account"
  project_id = module.project.project_id
  name       = "sa-monitoring"
  iam = {
    "roles/iam.workloadIdentityUser" = [
      "serviceAccount:${module.cluster.workload_identity_pool}[monitoring/frontend]",
      "serviceAccount:${module.cluster.workload_identity_pool}[monitoring/custom-metrics-stackdriver-adapter]"
    ]
  }
}

module "docker_artifact_registry" {
  source     = "./cloud-foundation-fabric/modules/artifact-registry"
  project_id = module.project.project_id
  location   = var.region
  name       = "registry"
  iam = {
    "roles/artifactregistry.reader" = [module.node_sa.iam_email]
  }
}
