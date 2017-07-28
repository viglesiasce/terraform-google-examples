# Global HTTP Example to GCE instances with NAT Gateway

**Figure 1.** *diagram of Google Cloud resources*

![architecture diagram](./diagram.png)

## Setup Environment

```
export GOOGLE_CREDENTIALS=$(cat ~/.config/gcloud/service_account.json)
export GOOGLE_PROJECT=$(gcloud config get-value project)
```

> See also: [Creating a Terraform Service Account](https://www.terraform.io/docs/providers/google/index.html#authentication-json-file).

## Run Terraform

```
terraform get
terraform plan
terraform apply
```

Open URL of load balancer in browser:

```
EXTERNAL_IP=$(terraform output -module gce-lb-http | grep external_ip | cut -d = -f2 | xargs echo -n)
open http://${EXTERNAL_IP}
```

> Wait for all instance to become healthy per output of: `gcloud compute backend-services get-health group-http-lb-backend-0 --global`. This may take several minutes.

You should see the instance details from `group1`.

## Cleanup

Remove all resources created by terraform:

```
terraform destroy
```