variable region {
  default = "us-west1"
}

provider google {
  region = "${var.region}"
}

data "template_file" "group1-startup-script" {
  template = "${file("${format("%s/../scripts/gceme.sh.tpl", path.module)}")}"

  vars {
    PROXY_PATH = ""
  }
}

module "mig1" {
  source            = "github.com/danisla/terraform-google-managed-instance-group"
  region            = "us-west1"
  zone              = "us-west1-b"
  name              = "group1"
  size              = 2
  access_config     = []
  target_tags       = ["allow-group1", "nat-us-west1"]
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.group1-startup-script.rendered}"
  depends_id        = "${module.nat.depends_id}"
}

module "nat" {
  source  = "github.com/danisla/terraform-google-nat-gateway"
  region  = "us-west1"
  network = "default"
}

module "gce-lb-http" {
  source      = "github.com/danisla/terraform-google-lb-http"
  name        = "group-http-lb"
  target_tags = ["allow-group1"]

  backends = {
    "0" = [
      {
        group = "${module.mig1.instance_group}"
      },
    ]
  }

  backend_params = [
    // health check path, port name, port number, timeout seconds.
    "/,http,80,10",
  ]
}
