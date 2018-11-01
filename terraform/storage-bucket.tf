provider "google" {
  version = "1.19.1"
  project = "${var.project}"
  region  = "${var.region}"
}

module "storage-bucket" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.1.1"
  name    = ["reddit-bucket1", "reddit-bucket2"]
}

output storage-bucket_url {
  value = "${module.storage-bucket.url}"
}
