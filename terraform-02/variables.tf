variable "location" {
  type = string
  default = "East US"
}
variable "subnet_name" {
  type = string
  default = "subnet1"
}
variable "private_ip_allocation" {
  type = string
  default = "Dynamic"
}

variable "vm_name" {
  type = string
  default = "my-ubuntu"
}
variable "username" {
  type = string
  default = "azureadmin"
}

variable "hostname" {
  type = string
  default = "hostname"
}