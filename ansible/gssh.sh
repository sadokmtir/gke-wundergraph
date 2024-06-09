#!/bin/bash

host="${@: -2: 1}"
cmd="${@: -1: 1}"

gcloud_args="
--tunnel-through-iap
--zone=europe-west1-b
--project=gke-autopilot-wunder
--quiet
--no-user-output-enabled
--
-C
"

exec gcloud compute ssh "$host" $gcloud_args "$cmd"