provider "vsphere" {
  user                 = "${var.vsphere_user}"
  password             = "${var.vsphere_password}"
  vsphere_server       = "${var.vsphere_server}"
  allow_unverified_ssl = true
}

variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}

# Datacenter
data "vsphere_datacenter" "dc" {
  name = "Datacenter"
}

# Cluster
data "vsphere_compute_cluster" "cluster" {
  name          = "Cluster"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Datastore-VM
data "vsphere_datastore" "datastore" {
  name          = "ESXI-Datastore"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Datastore-ISO
data "vsphere_datastore" "datastore-iso" {
  name          = "Data"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "Cluster/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Network
data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Virtual Machine
resource "vsphere_virtual_machine" "vm" {
  name             = "MyNewVM"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 4096
  guest_id = "ubuntu64Guest"
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0

  # Disk configuration
  disk {
    label            = "disk0"
    size             = 50 # Disk size in GB
    eagerly_scrub    = false
    thin_provisioned = true
  }

  # Network configuration
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  # CD-ROM/ISO configuration
  cdrom {
    client_device = false
    datastore_id  = data.vsphere_datastore.datastore-iso.id
    path          = "/ISO/ubuntu-22.04.3-desktop-amd64.iso"
  }

  # Boot options
  boot_delay = 5000 # Add a boot delay (5 seconds) to allow console access during ISO boot

  # Additional hardware settings
  firmware = "efi" # Use EFI firmware; change to "bios" if required
}
