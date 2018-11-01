variable public_key_path {
  description = "Path to the public key used to connect to the instance"
}

variable zone {
  description = "Zone"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable machine_type {
  description = "Instance machine type"
  default     = "g1-small"
}

variable network {
  description = "Network for instances"
}
