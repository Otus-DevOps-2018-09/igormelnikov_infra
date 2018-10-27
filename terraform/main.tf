provider "google" {
  version = "1.19.1"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_project_metadata_item" "ssh-users" {
  key = "ssh-keys"

  value = "appuser:${file(var.public_key_path)} appuser1:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtjAKQ5NCk4B2Ner72PVNHEHddOGUJKir65Lex1No6bD6rqBPgzrLCy4TYTLWHZXOLzqUG8yAqGdbtiTG8+I8tM9M0zvPu76b3h0HB9xTjfwYLY5Pxs5j6ncha4EiOkTPa0vTY4J5tnGBFIu6d8rOQJBJNxaAeFjAq3RZaG9VmPM+z2Jl8Zf5H0jbMIYEqNPmlLudAfgXNRpE8h9QrFA+B/pfTjWuXn8qEii0ioDWhNdBipL4zSXJPs3eiarPF3zzWTT3HTbvZGnPdpJPzkubA0P/8cUSYk//YrinyvH7WpGl+/cuHGm5ScVWB8U8vow3XzkaySQpBLtbVHyIBtmyr appuser1\n appuser2:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtjAKQ5NCk4B2Ner72PVNHEHddOGUJKir65Lex1No6bD6rqBPgzrLCy4TYTLWHZXOLzqUG8yAqGdbtiTG8+I8tM9M0zvPu76b3h0HB9xTjfwYLY5Pxs5j6ncha4EiOkTPa0vTY4J5tnGBFIu6d8rOQJBJNxaAeFjAq3RZaG9VmPM+z2Jl8Zf5H0jbMIYEqNPmlLudAfgXNRpE8h9QrFA+B/pfTjWuXn8qEii0ioDWhNdBipL4zSXJPs3eiarPF3zzWTT3HTbvZGnPdpJPzkubA0P/8cUSYk//YrinyvH7WpGl+/cuHGm5ScVWB8U8vow3XzkaySQpBLtbVHyIBtmyr appuser2"
}

resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = "${var.zone}"

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  tags = ["reddit-app"]

  network_interface {
    network       = "default"
    access_config = {}
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}
