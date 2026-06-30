module "example_vm" {
  source = "../../"

  name          = "example-vm"
  target_node   = "pve-node-1"
  clone         = "ubuntu-template"
  storage       = "local-lvm"
  instance_size = "medium"

  bridge = "vmbr0"
  model  = "virtio"

  ciuser     = "ubuntu"
  cipassword = var.cipassword
  sshkeys    = var.sshkeys
}
