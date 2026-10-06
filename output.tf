output "public_ip" {
  value = aws_spot_instance_request.open_web_ui.public_ip

}
output "open-web-ui-password" {
  sensitive = true
  value = random_password.open_web_ui_password.result
}
