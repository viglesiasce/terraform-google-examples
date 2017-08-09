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

module "k8s" {
  source        = "github.com/danisla/terraform-google-k8s-gce"
  name          = "dev"
  network       = "default"
  region        = "${var.region}"
  zone          = "${var.zone}"
  k8s_version   = "1.7.3"
  access_config = []
  add_tags      = ["nat-us-central1"]
  num_nodes     = "${var.num_nodes}"
  depends_id    = "${module.nat.depends_id}"
}

module "nat" {
  source  = "github.com/danisla/terraform-google-nat-gateway"
  region  = "us-central1"
  network = "default"
}
