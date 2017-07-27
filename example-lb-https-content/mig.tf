data "template_file" "group1-west-startup-script" {
  template = "${file("${format("%s/gceme.sh.tpl", path.module)}")}"

  vars {
    PROXY_PATH = "/group1"
  }
}

data "template_file" "group2-central-startup-script" {
  template = "${file("${format("%s/gceme.sh.tpl", path.module)}")}"

  vars {
    PROXY_PATH = "/group2"
  }
}

data "template_file" "group3-east-startup-script" {
  template = "${file("${format("%s/gceme.sh.tpl", path.module)}")}"

  vars {
    PROXY_PATH = "/group3"
  }
}

module "mig1" {
  source            = "github.com/danisla/terraform-google-managed-instance-group"
  region            = "us-west1"
  zone              = "us-west1-b"
  name              = "group1-west"
  size              = 2
  target_tags       = ["allow-group1"]
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.group1-west-startup-script.rendered}"
}

module "mig2" {
  source            = "github.com/danisla/terraform-google-managed-instance-group"
  region            = "us-central1"
  zone              = "us-central1-b"
  name              = "group2-central"
  size              = 2
  target_tags       = ["allow-group2"]
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.group2-central-startup-script.rendered}"
}

module "mig3" {
  source            = "github.com/danisla/terraform-google-managed-instance-group"
  region            = "us-east1"
  zone              = "us-east1-b"
  name              = "group3-east"
  size              = 2
  target_tags       = ["allow-group3"]
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.group3-east-startup-script.rendered}"
}
