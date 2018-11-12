terraform {
  backend "gcs" {
    bucket = "reddit-state-stage"
  }
}
