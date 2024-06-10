# Introduction

This repos presents the necessary configuration to bootstrap a **GKE private cluster**, connect to it through bastion VM using **Identity-Aware Proxy (IAP) TCP forwarding** and deploy the **[Wundergraph Router](https://github.com/wundergraph/cosmo/tree/main/helm/cosmo/charts/router)** using helm Chart.

# Infrastrure

The terraform code used too bootstrap the infrastructure is based on the **[Cloud Foundation Fabric](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric)**

# Project Set-up

1. Create the GCP project using gcloud for example `export PROJECT_NAME=wundergraph-gke && gcloud projects create $PROJECT_NAME`.

2. Create the service account that would be used with terrafrom:

````
gcloud iam service-accounts keys create terraform-private-key.json \
 --iam-account=terraform@gke-autopilot-wunder.iam.gserviceaccount.com```
````

3. Enable billing account for project:

   ```
   gcloud services enable cloudresourcemanager.googleapis.com --project $PROJECT_NAME
   export ACCOUNT_ID=YOUR_ACCOUNT_ID && gcloud beta billing projects link $PROJECT_NAME --billing-account $ACCOUNT_ID`
   ```

4. Add an IAM policy binding to a Cloud Billing account

gcloud alpha billing accounts add-iam-policy-binding $ACCOUND_ID \
 --member "serviceAccount:terraform@gke-autopilot-wunder.iam.gserviceaccount.com" \
 --role="roles/billing.user"

5. Set-up required roles for the service account:

```
gcloud projects add-iam-policy-binding gke-autopilot-wunder \
  --member="serviceAccount:terraform@gke-autopilot-wunder.iam.gserviceaccount.com" \
  --role="roles/browser" \
  --role="roles/serviceusage.serviceUsageAdmin" \
  --role="roles/iam.serviceAccountAdmin" \
  --role="roles/container.admin" \
  --role="roles/storage.admin" \
  --role="roles/cloudbuild.builds.editor" \
  --role="roles/container.nodeServiceAccount" \
  --role="roles/viewer" \
  --role="roles/monitoring.viewer" \
  --role="roles/compute.networkAdmin" \
  --role="roles/artifactregistry.admin" \
  --role="roles/compute.instanceAdmin.v1" \
  --role="roles/compute.admin" \
  --role="roles/iam.serviceAccountUser" \
  --role="roles/resourcemanager.projectIamAdmin" \
  --role="roles/container.clusterAdmin" \
  --role="roles/dns.admin"
```

6. Initialize Git repo with submodules: `git clone --recurse-submodules REPO_URL`

7. Set-up the env variables:

   - using the generated key from step 2 `export GOOGLE_APPLICATION_CREDENTIALS=/path/to/terraform-private-key.json`

   - set-up the google region: `export GOOGLE_REGION=europe-west3` and the zone for the bastion vm. `export VM_ZONE=$GOOGLE_REGION-b`

8. Initialize terraform plan: `terraform plan -out terraplan  --var-file=./envs/dev.tfvars`

9. Validate and apply the plan: `terraform apply terraplan`

10. Get the full ssh command that you need to launch each time to create the IAP proxy enabling communicating with
    GKE: `gcloud compute ssh mgmt --tunnel-through-iap --zone=$VM_ZONE-b --project=$PROJECT_NAME -- -L 8888:localhost:8888 -N -q -f > connect.sh && echo chmod +x connect.sh`

11. Set-up the proxy for the helm and kubectl client: `export HTTPS_PROXY=localhost:8888`

12. Create the namespace for deploying the wundergraph router: `kubectl create namespace router`

13. Finally, deploy the wundergraph router: `helm upgrade router --install --atomic --wait --namespace router ./router`

# Project tear-down

Run Terrafrom commands:

```
terraform plan -destroy -out destroyplan  --var-file=./envs/dev.tfvars
terraform apply destroyplan
```

Because of [GCP ISSUE](https://github.com/hashicorp/terraform-provider-google/issues/9812) run `gcloud compute network-endpoint-groups list` and for each NEG listed, run `gcloud compute network-endpoint-groups delete NAME --zone ZONE` and run again `terraform destroy` to delete the rest of the infrastructure.
