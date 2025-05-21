#------------------------------------- Connect to vSphere ----------------------------------------#

provider "vsphere" {
  user                 = "YOUR-USERNAME-VCENTER" # Replace with your username that you login on vcenter
  password             = "YOUR-PASSWORD-VCENTER" # Replace with your password that you login on vcenter
  vsphere_server       = "VCENTER-URL" # Replace with VCenter URL
  allow_unverified_ssl = true
}

#-------------------------------------------------------------------------------------------------#
#------------------------- Fetch Information About vSphere Environment ---------------------------#

data "vsphere_datacenter" "dc" {
  name = "YOUR-DATACENTER-NAME" # Replace with Datacenter name
}

data "vsphere_datastore" "ds" {
  name          = "YOUR-DATASTORE-NAME" # Replace with Datastore name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.os_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Data source to find the existing category
data "vsphere_tag_category" "backup_category" {
  name = "Backup"  # The name of your existing category
}

# Data source to find the existing tag
data "vsphere_tag" "backup_tag" {
  name        = var.new_vm_tags_for_backup
  category_id = data.vsphere_tag_category.backup_category.id
}

data "vsphere_host" "target_host" {
  name          = "YOUR-SERVER-ON-VECENTER" # Replace with name of specific server or resource pool 
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Fetch the Distributed Switch (vDS) dynamically based on the existing VM's network
data "vsphere_distributed_virtual_switch" "vds" {
  name          =  "Data Switch-Operation-LACP" # Replace with your distrubute switch
  datacenter_id = data.vsphere_datacenter.dc.id

}

# Manually set the portgroup name for now
data "vsphere_network" "network" {
  name          = var.new_vm_vlan
  datacenter_id = data.vsphere_datacenter.dc.id
}

#-------------------------------------------------------------------------------------------------#
#--------------------------------- Create New Virtual Machine ------------------------------------#

resource "vsphere_virtual_machine" "new_vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_host.target_host.resource_pool_id
  datastore_id     = data.vsphere_datastore.ds.id
  folder           = "Operation/Linux/Terraform"
  tags             = [data.vsphere_tag.backup_tag.id]
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  firmware         = data.vsphere_virtual_machine.template.firmware
  network_interface {
      network_id   = data.vsphere_network.network.id
      adapter_type = "vmxnet3"
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = var.new_os_hostname
        domain    = "example.com"
      }

      # Network Interface Configuration
      network_interface {
        ipv4_address = var.new_vm_ip
        ipv4_netmask = var.new_vm_netmask
      }

      # Set the Gateway (this goes outside the network_interface block)
      ipv4_gateway = var.new_vm_gateway

    }
  }

  # Set CPU and Memory Based on Existing VM
  num_cpus             = var.cpu_core
  num_cores_per_socket = var.cpu_socket
  memory               = var.ram


#  # Configure Disks for the New VM
  disk {
    label            = "disk00"
    size             = data.vsphere_virtual_machine.template.disks[0].size
    unit_number      = 0
    eagerly_scrub    = true
    thin_provisioned = false
  }

  disk {
    label            = "disk01"
    size             = data.vsphere_virtual_machine.template.disks[1].size
    unit_number      = 1
    eagerly_scrub    = true
    thin_provisioned = false
  }

  # Conditionally add the third disk if it exists
  dynamic "disk" {
    for_each = length(data.vsphere_virtual_machine.template.disks) > 2 ? [data.vsphere_virtual_machine.template.disks[2]] : []
    content {
      label            = "disk02"
      size             = disk.value.size
      unit_number      = 2
      eagerly_scrub    = true
      thin_provisioned = false
    }
  }

}
#-------------------------------------------------------------------------------------------------#
