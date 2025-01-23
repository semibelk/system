provider "vsphere" {
  user     = "terraform"
  password = "Terraform123!"
  vsphere_server = "192.168.1.102"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "vmname"
  datacenter_id    = "192.168.1.101"

  num_cpus = 2
  memory   = 2048

  network_interface {
    label = "VM Network"
    ipv4_address = "192.168.1.92"
    ipv4_prefix_length = 24
    ipv4_gateway = "192.168.1.1"
  }

  disk {
    label = "disk0"
    size  = 20
  }

  cdrom {
    datastore_id = "Data"
    path = "[datastore1] ISO/ubuntu-22.04.3-desktop-amd64.iso"
  }
}