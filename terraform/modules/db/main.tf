resource "google_compute_instance" "db" {
  name         = "reddit-db"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  tags         = ["reddit-db"]
  labels = {
    "db" = ""
  }

  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  network_interface {
    network       = "${var.network}"
    access_config = {}
  }
}

resource "null_resource" "provisioner-db" {
  count = "${var.use_provisioner ? 1 : 0}"

  triggers {
    db_id = "google_compute_instance.db.id"
  }

  connection {
    host        = "${google_compute_instance.db.network_interface.0.access_config.0.assigned_nat_ip}"
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
    source      = "${path.module}/mongod.conf"
    destination = "/tmp/mongod.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/mongod.conf /etc/mongod.conf",
      "sudo service mongod restart",
    ]
  }
}

resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-default"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  target_tags = ["reddit-db"]
  source_tags = ["reddit-app"]
}
