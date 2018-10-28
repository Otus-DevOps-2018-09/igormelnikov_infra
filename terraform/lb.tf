resource "google_compute_instance_group" "main" {
  name = "reddit-group"
  zone = "${var.zone}"

  named_port {
    name = "puma-port"
    port = 9292
  }

  instances = [
    "${google_compute_instance.app.self_link}",
    "${google_compute_instance.app2.self_link}",
  ]
}

resource "google_compute_backend_service" "default" {
  name      = "reddit-backend"
  port_name = "puma-port"
  protocol  = "HTTP"

  backend {
    group = "${google_compute_instance_group.main.self_link}"
  }

  health_checks = ["${google_compute_http_health_check.default.self_link}"]
}

resource "google_compute_http_health_check" "default" {
  name = "puma-check"
  port = "9292"
}

resource "google_compute_url_map" "default" {
  name            = "reddit-map"
  default_service = "${google_compute_backend_service.default.self_link}"
}

resource "google_compute_target_http_proxy" "default" {
  name    = "reddit-proxy"
  url_map = "${google_compute_url_map.default.self_link}"
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "reddit-rule"
  target     = "${google_compute_target_http_proxy.default.self_link}"
  port_range = "80"
}
