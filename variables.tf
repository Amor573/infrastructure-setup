variable "vsphere_server" {
  description = "vCenter or ESXi server hostname or IP"
  type        = string
}

variable "vsphere_user" {
  description = "vCenter/ESXi username"
  type        = string
  sensitive   = true
}

variable "vsphere_password" {
  description = "vCenter/ESXi password"
  type        = string
  sensitive   = true
}

variable "datacenter" {
  description = "Datacenter name (ha-datacenter for ESXi)"
  type        = string
}

variable "datastore" {
  description = "Datastore name"
  type        = string
}

variable "network_app_ingress" {
  description = "Ingress network for Kubernetes nodes"
  type        = string
}

variable "network_internal_mgmt" {
  description = "Internal management network for LB VM"
  type        = string
}

variable "iso_path" {
  description = "Path to Ubuntu ISO on datastore"
  type        = string
}
