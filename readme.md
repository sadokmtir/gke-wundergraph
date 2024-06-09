- gcloud projects create gke-autopilot-wunder
- export GOOGLE_APPLICATION_CREDENTIALS=/path/to/terraform-private-key.json
- expport GOOGLE_PROJECT=gke-autopilot-wunder
- export GOOGLE_REGION=europe-west3
- gcloud iam service-accounts create terraform

- gcloud iam service-accounts keys create terraform-private-key.json \
  --iam-account=terraform@gke-autopilot-wunder.iam.gserviceaccount.com

- enable billing:
  gcloud alpha billing accounts list --format json

- gcloud services enable cloudresourcemanager.googleapis.com --project gke-autopilot-wunder

# ^^ find an active billing account then

ACCOUNT_ID='0XYXYX-XYXYXY-XYXYXY'
gcloud beta billing projects link $PROJECTNAME --billing-account $ACCOUNT_ID

### git

git clone --recurse-submodules repo
#git submodule init && git submodule update
git pull --recurse-submodules

### roles needed

gcloud projects add-iam-policy-binding gke-autopilot-wunder \
 --member="serviceAccount:terraform@gke-autopilot-wunder.iam.gserviceaccount.com" \
 --role="roles/browser"

#add an IAM policy binding to a Cloud Billing account
gcloud alpha billing accounts add-iam-policy-binding 017297-8B6275-7C765F \
 --member "serviceAccount:terraform@gke-autopilot-wunder.iam.gserviceaccount.com" \
 --role="roles/billing.user"

gcloud projects add-iam-policy-binding gke-autopilot-wunder \
 --member="serviceAccount:terraform@gke-autopilot-wunder.iam.gserviceaccount.com" \
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

### To get the full ssh command

`gcloud compute ssh --tunnel-through-iap --zone=europe-west1-b --project=gke-autopilot-wunder --quiet --dry-run mgmt > connect.sh && chmod +x connect.sh`

MANAGEMENT VM:

sudo snap remove google-cloud-cli

kubectl create router
