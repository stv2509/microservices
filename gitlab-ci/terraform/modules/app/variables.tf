variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable sshuser {
  description = "SSH USER"
}

variable app_disk_image {
  description = "Disk image for gitlab server"
  default     = "ubuntu-1804-bionic-v20190320"
}
