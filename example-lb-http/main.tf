variable region {
  default = "us-central1"
}

variable network {
  default = "default"
}

provider google {
  region = "${var.region}"
}

module "gce-lb-http" {
  source      = "github.com/danisla/terraform-google-lb-http"
  name        = "group-http-lb"
  target_tags = ["${module.mig1.target_tags}", "${module.mig2.target_tags}"]
  network     = "${var.network}"

  backends = {
    "0" = [
      {
        group = "${module.mig1.instance_group}"
      },
      {
        group = "${module.mig2.instance_group}"
      },
    ]
  }

  backend_params = [
    // health check path, port name, port number, timeout seconds.
    "/,http,80,10",
  ]
}
