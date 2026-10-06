
variable "open_web_ui_user" {
  description = "The username for the Open Web UI VM"
  default     = "admin@demo.gs"
}
resource "random_password" "open_web_ui_password" {
  length           = 16
  special          = false
}
