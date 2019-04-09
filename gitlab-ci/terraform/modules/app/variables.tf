variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable sshuser {
  description = "SSH USER"
}

variable disk_image_family {
  description = "Disk image family for gitlab server"
  default     = "ubuntu-1804-lts"
}
