variable group1_size {
  default = "2"
}

variable group2_size {
  default = "2"
}

data "template_file" "group-startup-script" {
  template = "${file("${format("%s/../scripts/gceme.sh.tpl", path.module)}")}"

  vars {
    PROXY_PATH = ""
  }
}

module "mig1" {
  source            = "github.com/danisla/terraform-google-managed-instance-group"
  region            = "us-west1"
  zone              = "us-west1-b"
  network           = "${var.network}"
  name              = "group1"
  size              = "${var.group1_size}"
  target_tags       = ["allow-group1"]
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.group-startup-script.rendered}"
}

module "mig2" {
  source            = "github.com/danisla/terraform-google-managed-instance-group"
  region            = "us-east1"
  zone              = "us-east1-b"
  network           = "${var.network}"
  name              = "group2"
  size              = "${var.group2_size}"
  target_tags       = ["allow-group2"]
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.group-startup-script.rendered}"
}
