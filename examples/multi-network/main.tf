module "multi_network_vm" {
  source = "../../"

  name          = "multi-net-vm"
  target_node   = "pve-node-1"
  clone         = "ubuntu-template"
  storage       = "local-lvm"
  instance_size = "medium"

  networks = [
    {
      model  = "virtio"
      bridge = "vmbr0"
      tag    = 100
    },
    {
      model  = "virtio"
      bridge = "vmbr0"
      tag    = 200
      rate   = 1000
    },
  ]

  additional_disks = [
    {
      type    = "scsi"
      slot    = 2
      storage = "local-lvm"
      size    = "100G"
    },
  ]

  ipconfig0  = "ip=dhcp"
  ciuser     = "ubuntu"
  cipassword = var.cipassword
  sshkeys    = var.sshkeys
}
