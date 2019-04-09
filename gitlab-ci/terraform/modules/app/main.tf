resource "google_compute_instance" "app" {
  name         = "gitlab-ci"
  machine_type = "n1-standard-2"
  zone         = "europe-west1-b"
  tags         = ["http-server", "https-server", "docker-machine"]

  boot_disk {
    initialize_params {
      image = "${var.disk_image_family}"
      size  = "100"
    }
  }

  connection {
    type        = "ssh"
    user        = "${var.sshuser}"
    agent       = false
    private_key = "${file("~/.ssh/appuser")}"
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  metadata {
    ssh-keys = "${var.sshuser}:${file(var.public_key_path)}"
  }

provisioner "remote-exec" {
  inline = [
    "sudo ln -s /usr/bin/python3 /usr/bin/python",
  ]
}
}
