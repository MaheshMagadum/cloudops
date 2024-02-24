variable "location" {
  type = string
  default = "East US"
}
variable "cluster-name" {
  type = string
  default = "arocluster"
}

variable "aro_virtual_network_cidr_block" {
  type        = string
  default     = "10.1.0.0/23"
}

variable "aro_master_subnet_cidr_block" {
  type        = string
  default     = "10.1.0.0/27"
}

variable "aro_worker_subnet_cidr_block" {
  type        = string
  default     = "10.1.0.128/25"
}

variable "aro_firewall_subnet_cidr_block" {
  type        = string
  default     = "10.0.6.0/23"
}

variable "aro_private_endpoint_cidr_block" {
  type        = string
  default     = "10.0.8.0/23"
}

variable "aro_pod_cidr_block" {
  type        = string
  default     = "10.128.0.0/14"
}

variable "aro_service_cidr_block" {
  type        = string
  default     = "172.30.0.0/16"
}

variable "restrict_egress_traffic" {
  type        = bool
  default     = false
}

variable "api_server_profile" {
  type        = string
  default     = "Public"
}

variable "ingress_profile" {
  type        = string
  default     = "Public"
}

variable "aro_version" {
  type        = string
  default     = "4.13.23"
}

variable "domain" {
  type        = string
  description = "test"

}
variable "pull_secret_path" {
  type        = string
  default     = "pull-secret.txt"
}
variable "main_vm_size" {
  type        = string
  default     = "Standard_D8s_v3"
}

variable "worker_vm_size" {
  type        = string
  default     = "Standard_D4s_v3"
}

variable "worker_disk_size_gb" {
  type        = number
  default     = 128
}

variable "worker_node_count" {
  type        = number
  default     = 3
}