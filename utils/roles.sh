#!/bin/bash

# Define the roles that you want in an array
roles=(
  "roles/browser" 
  "roles/serviceusage.serviceUsageAdmin" 
  "roles/iam.serviceAccountAdmin" 
  "roles/container.admin" 
  "roles/storage.admin" 
  "roles/cloudbuild.builds.editor" 
  "roles/container.nodeServiceAccount" 
  "roles/viewer" 
  "roles/monitoring.viewer" 
  "roles/compute.networkAdmin" 
  "roles/artifactregistry.admin" 
  "roles/compute.instanceAdmin.v1" 
  "roles/compute.admin" 
  "roles/iam.serviceAccountUser" 
  "roles/resourcemanager.projectIamAdmin" 
  "roles/container.clusterAdmin" 
  "roles/dns.admin"
)

# Loop through each role and assign it to the service account
for role in "${roles[@]}"; do
    gcloud projects add-iam-policy-binding $PROJECT_NAME \
        --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
        --role="$role" 

done
