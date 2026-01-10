terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "~> 2.5"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

# -----------------------
# DATA SOURCES
# -----------------------

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_resource_pool" "pool" {
  name          = "Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "app_ingress" {
  name          = var.network_app_ingress
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "internal_mgmt" {
  name          = var.network_internal_mgmt
  datacenter_id = data.vsphere_datacenter.dc.id
}

# -----------------------
# VM DEFINITIONS
# -----------------------

# 1️⃣ CONTROL PLANE (7 nodes)
locals {
  controlplane_nodes = [
    "DevOps-POC-Dev-Master-60.30",
    "DevOps-POC-Stage-Master1-60.40",
    "DevOps-POC-Stage-Master2-60.41",
    "DevOps-POC-Stage-Master3-60.42",
    "DevOps-POC-Prod-Master1-60.50",
    "DevOps-POC-Prod-Master2-60.51",
    "DevOps-POC-Prod-Master3-60.52"
  ]

  worker_nodes = [
    "DevOps-POC-Dev-Worker1-60.31",
    "DevOps-POC-Dev-Worker2-60.32",
    "DevOps-POC-Stage-Worker1-60.43",
    "DevOps-POC-Stage-Worker2-60.44",
    "DevOps-POC-Stage-Worker3-60.45",
    "DevOps-POC-Prod-Worker1-60.53",
    "DevOps-POC-Prod-Worker2-60.54",
    "DevOps-POC-Prod-Worker3-60.55",
    "DevOps-POC-Prod-Worker4-60.56",
  ]

  loadbalancers = [
    "DevOps-POC-Stage-LB1-60.46",
    "DevOps-POC-Stage-LB2-60.47",
    "DevOps-POC-Prod-LB1-60.57",
    "DevOps-POC-Prod-LB2-60.58",
    "DevOps-POC-NFS-LB-50.52"
  ]

  nfs_nodes = [
    "DevOps-POC-NFS1-50.50",
    "DevOps-POC-NFS2-50.51"
  ]
}

# -----------------------
# CONTROL PLANE (count = 7)
# -----------------------

resource "vsphere_virtual_machine" "controlplane" {
  for_each         = { for name in local.controlplane_nodes : name => name }
  name             = each.key
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 4
  memory   = 8192
  guest_id = "ubuntu64Guest"

  wait_for_guest_ip_timeout  = 0
  wait_for_guest_net_timeout = 0

  network_interface {
    network_id   = data.vsphere_network.app_ingress.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "${each.key}-disk0"
    size             = 50
    thin_provisioned = true
  }

  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path         = var.iso_path
  }
}

# -----------------------
# WORKER NODES (count = 9)
# -----------------------

resource "vsphere_virtual_machine" "workers" {
  for_each         = { for name in local.worker_nodes : name => name }
  name             = each.key
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 4096
  guest_id = "ubuntu64Guest"

  wait_for_guest_ip_timeout  = 0
  wait_for_guest_net_timeout = 0

  network_interface {
    network_id   = data.vsphere_network.app_ingress.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "${each.key}-disk0"
    size             = 30
    thin_provisioned = true
  }

  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path         = var.iso_path
  }
}

# -----------------------
# LOAD BALANCERS (5 nodes)
# -----------------------

resource "vsphere_virtual_machine" "loadbalancers" {
  for_each         = { for name in local.loadbalancers : name => name }
  name             = each.key
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 4096
  guest_id = "ubuntu64Guest"

  wait_for_guest_ip_timeout  = 0
  wait_for_guest_net_timeout = 0

  network_interface {
    network_id   = data.vsphere_network.app_ingress.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "${each.key}-disk0"
    size             = 20
    thin_provisioned = true
  }

  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path         = var.iso_path
  }
}

# -----------------------
# JENKINS SERVER (1 node)
# -----------------------

resource "vsphere_virtual_machine" "jenkins" {
  name             = "DevOps-POC-Jenkins"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 4096
  guest_id = "ubuntu64Guest"

  wait_for_guest_ip_timeout  = 0
  wait_for_guest_net_timeout = 0

  network_interface {
    network_id   = data.vsphere_network.app_ingress.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "DevOps-POC-Jenkins-disk0"
    size             = 20
    thin_provisioned = true
  }

  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path         = var.iso_path
  }
}

# -----------------------
# NFS SERVERS (2 nodes)
# -----------------------

resource "vsphere_virtual_machine" "nfs" {
  for_each         = { for name in local.nfs_nodes : name => name }
  name             = each.key
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 4
  memory   = 8192
  guest_id = "ubuntu64Guest"

  wait_for_guest_ip_timeout  = 0
  wait_for_guest_net_timeout = 0

  network_interface {
    network_id   = data.vsphere_network.internal_mgmt.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "${each.key}-disk0"
    size             = 200
    thin_provisioned = true
  }

  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path         = var.iso_path
  }
}
