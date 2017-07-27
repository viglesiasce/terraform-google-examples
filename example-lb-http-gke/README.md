# HTTP load balancer with existing GKE cluster example

**Figure 1.** *diagram of Google Cloud resources*
![architecture diagram](./http_lb_gke_gcs_diagram.png)

## Setup Environment

```
export GOOGLE_CREDENTIALS=$(cat ~/.config/gcloud/service_account.json)
export GOOGLE_PROJECT=$(gcloud config get-value project)
export TF_VAR_backend_bucket="${GOOGLE_PROJECT}-static-assets"
```

> See also: [Creating a Terraform Service Account](https://www.terraform.io/docs/providers/google/index.html#authentication-json-file).

## Manually create GKE cluster (without Terraform)

In this example, we'll create a GKE cluster using the Cloud SDK and a Kubernetes `NodePort` service on port `30000` to route traffic to the [`example-app`](./k8s/example-app).

Create the GKE cluster named `dev` in zone `us-central1-f` with additional tags `gke-dev` used for load balancing:

```
gcloud container clusters create dev --num-nodes=3 --machine-type f1-micro --zone us-central1-f --tags gke-dev
```

> Remember to include the `--tags` argument so that the network rules apply.

Deploy the example app:

```
kubectl create -f example-app/
```

Find the URI of the instance groups for the GKE cluster, the groups created by GKE are prefixed with your cluster name:

```
gcloud compute instance-groups list --uri
```

Export the instance group URI as a Terraform environment variable:

```
export TF_VAR_backend=INSTANCE_GROUP_URI
```

Add a named port for the load balancer to the instance group:

```
gcloud compute instance-groups set-named-ports ${TF_VAR_backend} --named-ports=http:30000
```

> Backend Services use named ports to forward traffic and must be applied to the instance group.

## Run Terraform

```
terraform get
terraform plan
terraform apply
```

Open URL of load balancer in browser:

```
EXTERNAL_IP=$(terraform output -module gce-lb-http | grep external_ip | cut -d = -f2 | xargs echo -n)
open http://${EXTERNAL_IP}/
```

> Note that it may take several minutes for the global load balancer to be provisioned.

You should see the Google Cloud logo (served from Cloud Storage) and instance details for the sample-app running in the GKE cluster.

## Cleanup

```
terraform destroy
```

Delete the GKE cluster:

```
gcloud container clusters delete dev
```