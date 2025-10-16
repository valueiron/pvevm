resource "proxmox_vm_qemu" "pvevm" {
  count        = var.instance_count
  name         = var.name != "" && var.instance_count > 1 ? "${var.name}${count.index + 1}" : var.name
  vmid         = (var.instance_count > 1 ? (var.vmid == 0 ? 0 : var.vmid + count.index) : var.vmid)
  description  = var.notes
  target_node  = var.target_node
  target_nodes = var.target_nodes
  clone        = var.clone
  memory       = coalesce(var.memory, lookup(var.instance_sizes, var.instance_size, var.instance_sizes["small"]).memory)
  scsihw       = var.scsihw
  
  cpu {
    cores   = var.cpu != null ? var.cpu.cores : coalesce(var.cores, lookup(var.instance_sizes, var.instance_size, var.instance_sizes["small"]).cores)
    sockets = var.cpu != null ? var.cpu.sockets : coalesce(var.sockets, lookup(var.instance_sizes, var.instance_size, var.instance_sizes["small"]).sockets)
    vcores  = var.cpu != null ? var.cpu.vcores : coalesce(var.vcpus, lookup(var.instance_sizes, var.instance_size, var.instance_sizes["small"]).vcores)
  }
  
  agent        = var.agent
  tags         = var.tags
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
            storage   = scsi2.value.storage
            size      = scsi2.value.size
            format    = scsi2.value.format
            cache     = scsi2.value.cache
            backup    = scsi2.value.backup
            iothread  = scsi2.value.iothread
            replicate = scsi2.value.replicate
            ssd       = scsi2.value.ssd
            discard   = scsi2.value.discard
          }
        }
      }
      
      dynamic "scsi3" {
        for_each = [for disk in var.additional_disks : disk if disk.type == "scsi" && disk.slot == 3]
        content {
          disk {
            storage   = scsi3.value.storage
            size      = scsi3.value.size
            format    = scsi3.value.format
            cache     = scsi3.value.cache
            backup    = scsi3.value.backup
            iothread  = scsi3.value.iothread
            replicate = scsi3.value.replicate
            ssd       = scsi3.value.ssd
            discard   = scsi3.value.discard
          }
        }
      }
      
      dynamic "scsi4" {
        for_each = [for disk in var.additional_disks : disk if disk.type == "scsi" && disk.slot == 4]
        content {
          disk {
            storage   = scsi4.value.storage
            size      = scsi4.value.size
            format    = scsi4.value.format
            cache     = scsi4.value.cache
            backup    = scsi4.value.backup
            iothread  = scsi4.value.iothread
            replicate = scsi4.value.replicate
            ssd       = scsi4.value.ssd
            discard   = scsi4.value.discard
          }
        }
      }
      
      dynamic "scsi5" {
        for_each = [for disk in var.additional_disks : disk if disk.type == "scsi" && disk.slot == 5]
        content {
          disk {
            storage   = scsi5.value.storage
            size      = scsi5.value.size
            format    = scsi5.value.format
            cache     = scsi5.value.cache
            backup    = scsi5.value.backup
            iothread  = scsi5.value.iothread
            replicate = scsi5.value.replicate
            ssd       = scsi5.value.ssd
            discard   = scsi5.value.discard
          }
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
