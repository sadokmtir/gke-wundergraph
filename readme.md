# Introduction

This repos presents the necessary configuration to bootstrap a **GKE private
cluster**, connect to it through bastion VM using **Identity-Aware Proxy (IAP)
TCP forwarding** and deploy the
**[Wundergraph Router](https://github.com/wundergraph/cosmo/tree/main/helm/cosmo/charts/router)**
using helm Chart.

# Infrastrure

The terraform code used too bootstrap the infrastructure is based on the
**[Cloud Foundation Fabric](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric)**

# Project Set-up

1. Initialize Git repo with submodules:
   `git clone --recurse-submodules REPO_URL`

2. Create the GCP project using gcloud for example
   `export PROJECT_NAME=gke-autopilot-wunder && gcloud projects create $PROJECT_NAME`.

3. Create the service account that would be used with terrafrom:

```
gcloud iam service-accounts create terraform --project=$PROJECT_NAME

gcloud iam service-accounts keys create terraform-private-key.json \
 --iam-account=terraform@gke-autopilot-wunder.iam.gserviceaccount.com
```

4. Enable billing account for project:

```
gcloud services enable cloudresourcemanager.googleapis.com --project $PROJECT_NAME
export ACCOUNT_ID=YOUR_ACCOUNT_ID && gcloud beta billing projects link $PROJECT_NAME --billing-account $ACCOUNT_ID`
```

5. Set-up required roles for the service account:

```
export SERVICE_ACCOUNT_EMAIL=serviceAccount:terraform@gke-autopilot-wunder.iam.gserviceaccount.com

./utils/roles.sh
```

6. Set-up the env variables:

   - using the generated key from step 2
     `export GOOGLE_APPLICATION_CREDENTIALS=/path/to/terraform-private-key.json`

   - set-up the google region: `export GOOGLE_REGION=europe-west1` and the zone
     for the bastion vm. `export VM_ZONE=$GOOGLE_REGION-b`

   - set up project id and region for terraform use:

     ```
     export TF_VAR_project_id=$PROJECT_NAME
     export TF_VAR_region=$GOOGLE_REGION
     ```

7. Create terraform plan: `terraform init`

8. Initialize terraform plan:
   `terraform plan -out terraplan --var-file=./envs/dev.tfvars`

9. Validate and apply the plan: `terraform apply terraplan`

10. Provison required tools for bastion vm using ansible:
    `cd ansible && ansible-playbook -v playbook.yaml`

11. Get the full ssh command that you need to launch each time to create the IAP
    proxy enabling communicating with GKE:
    `gcloud compute ssh mgmt --tunnel-through-iap --zone=$VM_ZONE --project=$PROJECT_NAME --dry-run -- -L 8888:localhost:8888 -N -q -f > connect.sh && chmod +x connect.sh && echo export HTTPS_PROXY=localhost:8888 >> .connect.sh`

12. Set-up the proxy for the helm and kubectl client:
    `export HTTPS_PROXY=localhost:8888`

13. Create the namespace for deploying the wundergraph router:
    `kubectl create namespace router`

14. Finally, deploy the wundergraph router:
    `helm upgrade router --install --atomic --wait --namespace router ./router`

# Project tear-down

Run Terrafrom commands:

```

terraform plan -destroy -out destroyplan --var-file=./envs/dev.tfvars terraform
apply destroyplan

```

Because of
[GCP ISSUE](https://github.com/hashicorp/terraform-provider-google/issues/9812)
run `gcloud compute network-endpoint-groups list` and for each NEG listed, run
`gcloud compute network-endpoint-groups delete NAME --zone ZONE` and run again
`terraform destroy` to delete the rest of the infrastructure.

```

```
