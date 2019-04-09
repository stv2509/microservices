provider "google" {
  project = "${var.project}"
  region  = "${var.region}"
}

module "app" {
  source            = "../modules/app"
  public_key_path   = "${var.public_key_path}"
  disk_image_family = "${var.disk_image_family}"
  sshuser           = "${var.sshuser}"
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["0.0.0.0/0"]
}
