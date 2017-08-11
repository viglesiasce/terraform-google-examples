variable region {
  default = "us-central1"
}

variable zone {
  default = "us-central1-b"
}

provider google {
  region = "${var.region}"
}

variable num_nodes {
  default = 3
}

variable cluster_name {
  default = "dev"
}

module "k8s" {
  // source        = "github.com/danisla/terraform-google-k8s-gce"
  source = "/Users/disla/Projects/terraform-google-modules/terraform-google-k8s-gce"
  name          = "${var.cluster_name}"
  network       = "default"
  region        = "${var.region}"
  zone          = "${var.zone}"
  k8s_version   = "1.7.3"
  access_config = []
  add_tags      = ["nat-us-central1"]
  num_nodes     = "${var.num_nodes}"
  depends_id    = "${join(",", list(module.nat.depends_id, null_resource.route_cleanup.id))}"
}

module "nat" {
  source  = "github.com/danisla/terraform-google-nat-gateway"
  region  = "us-central1"
  network = "default"
}

resource "null_resource" "route_cleanup" {
  // Cleanup the routes after the managed instance groups have been deleted.
  provisioner "local-exec" {
    when    = "destroy"
    command = "gcloud compute routes list --filter='name~k8s-${var.cluster_name}.*' --format='get(name)' | tr '\n' ' ' | xargs -I {} sh -c 'echo Y|gcloud compute routes delete {}' || true"
  }
}
