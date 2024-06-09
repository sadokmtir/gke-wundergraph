#!/bin/bash

host="$${@: -2: 1}"
cmd="$${@: -1: 1}"

gcloud_args="
--tunnel-through-iap
--zone=${zone}
--project=${project_id}
--quiet
--no-user-output-enabled
--
-C
"

exec gcloud compute ssh "$host" $gcloud_args "$cmd"