output "gitlab_external_ip" {
  value = "${module.app.gitlab_external_ip}"
}

output "gitlab_internal_ip" {
  value = "${module.app.gitlab_internal_ip}"
}
