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

data "template_file" "nat-west-startup-script" {
  template = "${file("${format("%s/../scripts/nat_gateway.sh.tpl", path.module)}")}"
}

module "mig1" {
  source            = "github.com/danisla/terraform-google-managed-instance-group"
  region            = "us-west1"
  zone              = "us-west1-b"
  name              = "group1"
  size              = 2
  access_config     = []
  target_tags       = ["allow-group1","nat-west"]
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.group1-startup-script.rendered}"
  depends_id        = "${module.nat-west.depends_id}"
}

module "nat-west" {
  source            = "github.com/danisla/terraform-google-managed-instance-group"
  region            = "us-west1"
  zone              = "us-west1-b"
  name              = "nat-gateway-west"
  size              = 1
  network_ip        = "10.138.1.1"
  can_ip_forward    = "true"
  service_port      = "8080"
  service_port_name = "http"
  startup_script    = "${data.template_file.nat-west-startup-script.rendered}"
}

resource "google_compute_route" "nat-west" {
  name        = "nat-west"
  dest_range  = "0.0.0.0/0"
  network     = "default"
  next_hop_ip = "10.138.1.1"
  tags        = ["nat-west"]
  priority    = 800
  depends_on  = ["module.nat-west"]
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