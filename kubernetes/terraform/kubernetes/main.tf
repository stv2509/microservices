provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}


module "gke" {
  source                   = "../modules/gke"
  project                  = "${var.project}"
  region                   = "${var.region}"
  zone                     = "${var.zone}"
  cluster_name             = "${var.cluster_name}"
  defaultpool_machine_type = "${var.defaultpool_machine_type}"
  bigpool_machine_type     = "${var.bigpool_machine_type}"

  defaultpool_machine_size = "${var.defaultpool_machine_size}"
  bigpool_machine_size     = "${var.bigpool_machine_size}"

  defaultpool_nodes_count = "${var.bigpool_nodes_count}"
  bigpool_nodes_count     = "${var.bigpool_nodes_count}"

  min_master_version = "${var.min_master_version}"
}

resource "null_resource" "bootstrap_gke" {
  depends_on = ["module.gke"]
  provisioner "local-exec" {
    command = "../../bootstrap.sh ${var.cluster_name} ${var.zone} ${var.project}"
  }
}
