data "template_file" "group1-startup-script" {
  template = "${file("${format("%s/../scripts/nginx_upstream.sh.tpl", path.module)}")}"

  vars {
    UPSTREAM = "${module.gce-ilb.ip_address}"
  }
}

data "template_file" "group2-startup-script" {
  template = "${file("${format("%s/../scripts/gceme.sh.tpl", path.module)}")}"

  vars {
    PROXY_PATH = ""
  }
}

module "mig1" {
  source            = "github.com/danisla/terraform-google-managed-instance-group"
  region            = "${var.region}"
  zone              = "${var.zone}"
  name              = "group1"
  size              = 2
  target_tags       = ["allow-group1"]
  target_pools      = ["${module.gce-lb-fr.target_pool}"]
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.group1-startup-script.rendered}"
}

module "mig2" {
  source            = "github.com/danisla/terraform-google-managed-instance-group"
  region            = "${var.region}"
  zone              = "${var.zone}"
  name              = "group2"
  size              = 2
  target_tags       = ["allow-group2"]
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.group2-startup-script.rendered}"
}

module "mig3" {
  source            = "github.com/danisla/terraform-google-managed-instance-group"
  region            = "${var.region}"
  zone              = "us-central1-f"
  name              = "group3"
  size              = 2
  target_tags       = ["allow-group2"]
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.group2-startup-script.rendered}"
}
