variable region {
  default = "us-central1"
}

variable network {
  default = "default"
}

variable zone {
  default = "us-central1-b"
}

provider google {
  region = "${var.region}"
}

module "gce-lb-fr" {
  source       = "github.com/danisla/terraform-google-lb"
  region       = "${var.region}"
  network      = "${var.network}"
  name         = "group1-lb"
  service_port = "${module.mig1.service_port}"
  target_tags  = ["${module.mig1.target_tags}"]
}

module "gce-ilb" {
  source      = "github.com/danisla/terraform-google-lb-internal"
  region      = "${var.region}"
  name        = "group2-ilb"
  ports       = ["${module.mig2.service_port}"]
  health_port = "${module.mig2.service_port}"
  source_tags = ["${module.mig1.target_tags}"]
  target_tags = ["${module.mig2.target_tags}", "${module.mig3.target_tags}"]

  backends = [
    {
      group = "${module.mig2.instance_group}"
    },
    {
      group = "${module.mig3.instance_group}"
    },
  ]
}
