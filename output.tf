output "public_ip" {
  description = "Public IP of the Open Web UI instance"
  value       = aws_spot_instance_request.open_web_ui.public_ip

}
output "open-web-ui-password" {
  description = "Password for the Open Web UI admin user"
  sensitive   = true
  value       = random_password.open_web_ui_password.result
}
