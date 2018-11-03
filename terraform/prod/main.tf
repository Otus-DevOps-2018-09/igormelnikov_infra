provider "google" {
  version = "1.19.1"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_project_metadata_item" "ssh-users" {
  key   = "ssh-keys"
  value = "appuser:${file(var.public_key_path)}"
}

module "app" {
  source           = "../modules/app"
  public_key_path  = "${var.public_key_path}"
  private_key_path = "${var.private_key_path}"
  zone             = "${var.zone}"
  app_disk_image   = "${var.app_disk_image}"
  network          = "${var.network}"
  db_internal_ip   = "${module.db.db_internal_ip}"
}

module "db" {
  source           = "../modules/db"
  public_key_path  = "${var.public_key_path}"
  private_key_path = "${var.private_key_path}"
  zone             = "${var.zone}"
  db_disk_image    = "${var.db_disk_image}"
  network          = "${var.network}"
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["95.79.254.234/32"]
  network       = "${var.network}"
}
