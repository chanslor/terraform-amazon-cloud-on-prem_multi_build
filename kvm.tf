provider "libvirt" {
  uri = "qemu:///system"
}

#provider "libvirt" {
#  alias = "server2"
#  uri   = "qemu+ssh://root@192.168.100.10/system"
#}

resource "libvirt_volume" "aws-qcow2" {
  name = "${var.virtname}-aws.qcow2"
  pool = "default"
  source = "file:///var/lib/libvirt/images/amazon/amzn2-kvm-2.0.20190612-x86_64.xfs.gpt.qcow2"
  format = "qcow2"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/cloud_init.cfg")}"
}

data "template_file" "network_config" {
  template = "${file("${path.module}/network_config.cfg")}"
}



# Use CloudInit to add the instance
resource "libvirt_cloudinit_disk" "commoninit" {
  name = "${var.virtname}-commoninit.iso"
  user_data      = "${data.template_file.user_data.rendered}"
  network_config = "${data.template_file.network_config.rendered}"
}

# Define KVM domain to create
resource "libvirt_domain" "aws" {
  name   = "${var.virtname}"
  memory = "1024"
  vcpu   = 1

  network_interface {
    #From virsh net-list
    #network_name = "default"
    #network_name = "chanslor.edu"
    #network_name = "ip6"
    network_name = "vm_network"
  }

  disk {
    volume_id = "${libvirt_volume.aws-qcow2.id}"
  }

  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

# Output Server IP
# output "ip" {
#   value = "${libvirt_domain.aws.network_interface.0.addresses.0}"
# }
