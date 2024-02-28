variable "password" {
   description = "pass for Ansible"
   type = string
   sensitive = true
}
variable "host"{
   description = "The IP of my Ansible"
}
variable "access" {
   description = "my access_key for AWS"
   type = string
   sensitive = true
}
variable "secret" {
   description = "my secret_key for AWS"
   type = string
   sensitive = true
}