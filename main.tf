resource "proxmox_vm_qemu" "pvevm" {
  count        = var.instance_count
  name         = var.name != "" && var.instance_count > 1 ? "${var.name}${count.index + 1}" : var.name
  vmid         = (var.instance_count > 1 ? (var.vmid == 0 ? 0 : var.vmid + count.index) : var.vmid)
  desc         = var.notes
  target_node  = var.target_node
  target_nodes = var.target_nodes
  clone        = var.clone
  memory       = coalesce(var.memory, lookup(var.instance_sizes, var.instance_size, var.instance_sizes["small"]).memory)
  scsihw       = var.scsihw
  cores        = coalesce(var.cores, lookup(var.instance_sizes, var.instance_size, var.instance_sizes["small"]).cores)
  sockets      = coalesce(var.sockets, lookup(var.instance_sizes, var.instance_size, var.instance_sizes["small"]).sockets)
  vcpus        = coalesce(var.vcpus, lookup(var.instance_sizes, var.instance_size, var.instance_sizes["small"]).vcpus)
  agent        = var.agent
  tags         = var.tags
  serial {
    id = var.serial0
  }

  network {
    id     = var.id
    bridge = var.bridge
    model  = var.model
    tag    = var.tag
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = var.storage
          size    = coalesce(var.size, lookup(var.instance_sizes, var.instance_size, var.instance_sizes["small"]).size)
        }
      }
      scsi1 {
        cloudinit {
          storage = var.storage
        }
      }
    }
  }

  os_type      = var.ostype
  ipconfig0    = length(var.ip_addresses) > count.index ? format("ip=%s,gw=%s", var.ip_addresses[count.index], var.gateway) : var.ipconfig0
  nameserver   = var.nameserver
  ciuser       = var.ciuser
  cipassword   = var.cipassword
  searchdomain = var.searchdomain
  sshkeys      = var.sshkeys
}
