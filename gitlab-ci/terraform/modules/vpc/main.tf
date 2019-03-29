resource "google_compute_firewall" "firewall_ssh" {
  name        = "default-allow-ssh"
  network     = "default"
  description = "Allows SSH connections"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = "${var.source_ranges}"
}

resource "google_compute_firewall" "firewall_http" {
  name        = "default-allow-http"
  network     = "default"
  description = "Allows HTTP connections"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = "${var.source_ranges}"
}

resource "google_compute_firewall" "firewall_https" {
  name        = "default-allow-https"
  network     = "default"
  description = "Allows HTTP connections"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = "${var.source_ranges}"
}
