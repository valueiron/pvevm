resource "proxmox_vm_qemu" "pvevm" {
  name         = var.name
  vmid         = var.vmid
  description  = var.notes
  target_node  = var.target_node
  target_nodes = var.target_nodes
  clone        = var.clone
  memory       = coalesce(var.memory, lookup(var.instance_sizes, var.instance_size, var.instance_sizes["small"]).memory)
  scsihw       = var.scsihw
  pool         = var.pool

  cpu {
    cores   = var.cpu != null ? var.cpu.cores : coalesce(var.cores, lookup(var.instance_sizes, var.instance_size, var.instance_sizes["small"]).cores)
    sockets = var.cpu != null ? var.cpu.sockets : coalesce(var.sockets, lookup(var.instance_sizes, var.instance_size, var.instance_sizes["small"]).sockets)
    vcores  = var.cpu != null ? var.cpu.vcores : coalesce(var.vcpus, lookup(var.instance_sizes, var.instance_size, var.instance_sizes["small"]).vcores)
  }

  agent = var.agent
  # Normalize tags; provider rejects invalid whitespace-only strings
  tags  = length(trimspace(var.tags)) > 0 ? trimspace(var.tags) : null

  lifecycle {
    # Proxmox sometimes round-trips empty tags as a single space, causing drift
    ignore_changes = [tags,vmid]
  }
  serial {
    id = var.serial0
  }

  # Dynamic network blocks - use multiple networks if provided, otherwise fall back to single network
  dynamic "network" {
    for_each = length(var.networks) > 0 ? var.networks : [{
      id        = var.id
      bridge    = var.bridge
      model     = var.model
      tag       = var.tag
      firewall  = null
      link_down = null
      macaddr   = null
      queues    = null
      rate      = null
    }]

    content {
      id        = network.value.id
      bridge    = network.value.bridge
      model     = network.value.model
      tag       = network.value.tag
      firewall  = network.value.firewall
      link_down = network.value.link_down
      macaddr   = network.value.macaddr
      queues    = network.value.queues
      rate      = network.value.rate
    }
  }

  # Disk configuration with support for additional disks
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

      # Dynamic additional SCSI disks
      dynamic "scsi2" {
        for_each = [for disk in var.additional_disks : disk if disk.type == "scsi" && disk.slot == 2]
        content {
          disk {
            storage = scsi2.value.storage
            size    = scsi2.value.size
          }
        }
      }

      dynamic "scsi3" {
        for_each = [for disk in var.additional_disks : disk if disk.type == "scsi" && disk.slot == 3]
        content {
          disk {
            storage = scsi3.value.storage
            size    = scsi3.value.size
          }
        }
      }

      dynamic "scsi4" {
        for_each = [for disk in var.additional_disks : disk if disk.type == "scsi" && disk.slot == 4]
        content {
          disk {
            storage = scsi4.value.storage
            size    = scsi4.value.size
          }
        }
      }

      dynamic "scsi5" {
        for_each = [for disk in var.additional_disks : disk if disk.type == "scsi" && disk.slot == 5]
        content {
          disk {
            storage = scsi5.value.storage
            size    = scsi5.value.size
          }
        }
      }
    }
  }

  os_type      = var.ostype
  ipconfig0    = var.ipconfig0
  ipconfig1    = var.ipconfig1
  nameserver   = var.nameserver
  ciuser       = var.ciuser
  cipassword   = var.cipassword
  searchdomain = var.searchdomain
  sshkeys      = var.sshkeys
}
