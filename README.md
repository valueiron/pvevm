# Proxmox VM Terraform Module

A Terraform module for creating and managing Proxmox VMs using the Proxmox provider.

## Features

- Create single or multiple VMs
- Support for cloning from existing templates
- Cloud-init configuration
- Flexible CPU and memory allocation
- Network configuration
- Storage management
- Predefined instance sizes (xsmall, small, medium, large, xlarge)
- **NEW (feature/expansion)**: Multiple network interfaces support
- **NEW (feature/expansion)**: Additional disk configurations

## Requirements



## Provider Configuration



## Usage

### Basic Example

```hcl
module "example_vm" {
  source = "./modules/pvevm"
  
  name         = "example-vm"
  target_node  = "pve-node-1"
  clone        = "ubuntu-template"
  storage      = "local-lvm"
  instance_size = "medium"
  
  # Network configuration
  bridge = "vmbr0"
  model  = "virtio"
  
  # Cloud-init configuration
  ciuser     = "ubuntu"
  cipassword = "your-password"
  sshkeys    = file("~/.ssh/id_rsa.pub")
}
```


### Multiple VMs with for_each

```hcl
locals {
  vms = {
    web1 = {
      name         = "web-1"
      target_node  = "pve-node-1"
      clone        = "ubuntu-template"
      storage      = "local-lvm"
      instance_size = "small"
      ipconfig0    = "ip=192.168.10.11/24,gw=192.168.10.1"
    }
    db1 = {
      name         = "db-1"
      target_node  = "pve-node-2"
      clone        = "ubuntu-template"
      storage      = "nvme2-ceph"
      instance_size = "medium"
      ipconfig0    = "ip=192.168.10.21/24,gw=192.168.10.1"
    }
  }
}

module "vm" {
  source = "./modules/pvevm"
  for_each = local.vms

  name          = each.value.name
  target_node   = each.value.target_node
  clone         = each.value.clone
  storage       = each.value.storage
  instance_size = each.value.instance_size

  # Optional overrides
  ipconfig0 = try(each.value.ipconfig0, null)
  ipconfig1 = try(each.value.ipconfig1, null)
  networks  = try(each.value.networks, [])
  additional_disks = try(each.value.additional_disks, [])
}
```

To consume outputs with for_each, access them per key or build a map:

```hcl
# Per-VM access
module.vm["web1"].vm_id

# Build a map of IDs keyed by VM key
locals {
  vm_ids = { for k, m in module.vm : k => m.vm_id }
}
```



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the VM within Proxmox | `string` | n/a | yes |
| target_node | The name of the Proxmox Node on which to place the VM | `string` | `null` | no |
| clone | The base VM from which to clone to create the new VM | `string` | n/a | yes |
| storage | Disk Storage Location | `string` | n/a | yes |
| instance_size | The size of the instance (xsmall, small, medium, large, xlarge) | `string` | `""` | no |
| cpu | CPU configuration block | `object` | `null` | no |
| memory | The amount of memory to allocate to the VM in Megabytes | `number` | `null` | no |
| size | Disk Size | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| vm_ip | List of VM IP addresses |
| vm_name | List of VM names |
| vm_id | List of VM IDs |
| vm_vcpus | List of VM vCPU counts |
| vm_memory | List of VM memory allocations |
| vm_notes | List of VM descriptions/notes |
| vm_tags | List of VM tags |

## Instance Sizes

The module provides predefined instance sizes for quick deployment:

| Size | Memory | Cores | Sockets | vCores | Disk |
|------|--------|-------|---------|--------|------|
| xsmall | 2GB | 1 | 1 | 1 | 10GB |
| small | 4GB | 2 | 1 | 2 | 12GB |
| medium | 8GB | 4 | 1 | 4 | 20GB |
| large | 16GB | 8 | 1 | 8 | 40GB |
| xlarge | 32GB | 10 | 1 | 10 | 60GB |

## Recent Changes

### feature/expansion Branch - Multiple Networks and Disks

The `feature/expansion` branch adds powerful new capabilities:

1. **Multiple Network Interfaces**
   - Configure VMs with multiple NICs
   - Support for different VLANs per interface
   - Advanced network options (rate limiting, firewall, queues)
   - Backward compatible with single network configuration

2. **Additional Disk Support**
   - Add multiple additional disks (scsi2-scsi5)
   - Per-disk configuration (SSD, cache, backup, iothread)
   - Flexible storage allocation
   - Primary disk still configured via instance_size

**Example:**
```hcl
module "advanced_vm" {
  source = "github.com/valueiron/pvevm.git?ref=feature/expansion"
  
  # ... basic config ...
  
  networks = [
    { bridge = "vmbr0", tag = 100 },  # Management
    { bridge = "vmbr0", tag = 200 }   # Data
  ]
  
  additional_disks = [
    { type = "scsi", slot = 2, storage = "nvme2-ceph", size = "100G", ssd = true },
    { type = "scsi", slot = 3, storage = "local-lvm", size = "500G" }
  ]
}
```

See [examples/multiple-networks-disks.md](./examples/multiple-networks-disks.md) for detailed examples.

### v3.0.2-rc03 Upgrade (main branch)

This module has been updated to use Proxmox provider v3.0.2-rc03 with the following changes:

1. **Provider Version**: Updated from `3.0.1-rc8` to `3.0.2-rc03`
2. **Description Field**: `desc` parameter changed to `description`
3. **CPU Configuration**: Individual `cores`, `sockets`, and `vcpus` parameters replaced with a `cpu` block containing:
   - `cores`: Number of CPU cores per socket
   - `sockets`: Number of CPU sockets
   - `vcores`: Total number of virtual CPUs

The module maintains backward compatibility by still supporting the old individual parameters.

## License

This module is licensed under the MIT License.
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 3.0.2-rc03 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 3.0.2-rc03 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_vm_qemu.pvevm](https://registry.terraform.io/providers/Telmate/proxmox/3.0.2-rc03/docs/resources/vm_qemu) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_disks"></a> [additional\_disks](#input\_additional\_disks) | Additional disks to attach (beyond scsi0 boot and cloud-init) | <pre>list(object({<br/>    type    = string # scsi, sata, virtio, ide<br/>    storage = string # e.g., "local-lvm", "nvme2-ceph"<br/>    size    = string # e.g., "10G", "100G"<br/>    slot    = number # scsi2–scsi5 (slots 0–1 reserved)<br/>  }))</pre> | `[]` | no |
| <a name="input_agent"></a> [agent](#input\_agent) | Enable QEMU Guest Agent (1 enabled, 0 disabled) | `number` | `1` | no |
| <a name="input_bridge"></a> [bridge](#input\_bridge) | Network bridge to attach NICs to (e.g., vmbr0) | `string` | `"vmbr0"` | no |
| <a name="input_cipassword"></a> [cipassword](#input\_cipassword) | Cloud-init user password | `string` | n/a | yes |
| <a name="input_ciuser"></a> [ciuser](#input\_ciuser) | Cloud-init default user | `string` | n/a | yes |
| <a name="input_clone"></a> [clone](#input\_clone) | Source template or VM name to clone | `string` | n/a | yes |
| <a name="input_cores"></a> [cores](#input\_cores) | CPU cores per socket | `number` | `null` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Explicit CPU configuration (overrides cores/sockets/vcpus variables) | <pre>object({<br/>    cores   = number<br/>    sockets = number<br/>    vcores  = number<br/>  })</pre> | `null` | no |
| <a name="input_id"></a> [id](#input\_id) | NIC device ID/index as required by the provider | `number` | `0` | no |
| <a name="input_instance_size"></a> [instance\_size](#input\_instance\_size) | Preset size key (xsmall, small, medium, large, xlarge). Empty to use custom values | `string` | `""` | no |
| <a name="input_instance_sizes"></a> [instance\_sizes](#input\_instance\_sizes) | Map of size presets defining memory, cores, sockets, vcores, and disk size | <pre>map(object({<br/>    memory  = number<br/>    cores   = number<br/>    sockets = number<br/>    vcores  = number<br/>    size    = string<br/>  }))</pre> | <pre>{<br/>  "large": {<br/>    "cores": 8,<br/>    "memory": 16384,<br/>    "size": "40G",<br/>    "sockets": 1,<br/>    "vcores": 8<br/>  },<br/>  "medium": {<br/>    "cores": 4,<br/>    "memory": 8192,<br/>    "size": "20G",<br/>    "sockets": 1,<br/>    "vcores": 4<br/>  },<br/>  "small": {<br/>    "cores": 2,<br/>    "memory": 4096,<br/>    "size": "12G",<br/>    "sockets": 1,<br/>    "vcores": 2<br/>  },<br/>  "xlarge": {<br/>    "cores": 10,<br/>    "memory": 32768,<br/>    "size": "60G",<br/>    "sockets": 1,<br/>    "vcores": 10<br/>  },<br/>  "xsmall": {<br/>    "cores": 1,<br/>    "memory": 2048,<br/>    "size": "10G",<br/>    "sockets": 1,<br/>    "vcores": 1<br/>  }<br/>}</pre> | no |
| <a name="input_ipconfig0"></a> [ipconfig0](#input\_ipconfig0) | Cloud-init IP config for NIC 0 (e.g., ip=192.168.1.10/24,gw=192.168.1.1) | `string` | `"ip=dhcp"` | no |
| <a name="input_ipconfig1"></a> [ipconfig1](#input\_ipconfig1) | Cloud-init IP config for NIC 1 (same format as ipconfig0) | `string` | `null` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory allocated to the VM in MiB | `number` | `null` | no |
| <a name="input_model"></a> [model](#input\_model) | NIC model (e.g., virtio, e1000) | `string` | `"virtio"` | no |
| <a name="input_name"></a> [name](#input\_name) | VM name as it will appear in Proxmox | `string` | n/a | yes |
| <a name="input_nameserver"></a> [nameserver](#input\_nameserver) | Default DNS server for the guest | `string` | `null` | no |
| <a name="input_networks"></a> [networks](#input\_networks) | Optional NIC list. If empty, a single NIC is built from bridge/model/tag | <pre>list(object({<br/>    id        = optional(number, 0)<br/>    model     = optional(string, "virtio")<br/>    bridge    = optional(string, "vmbr0")<br/>    tag       = optional(number)<br/>    firewall  = optional(bool)<br/>    link_down = optional(bool)<br/>    macaddr   = optional(string)<br/>    queues    = optional(number)<br/>    rate      = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_notes"></a> [notes](#input\_notes) | Proxmox VM description/notes | `string` | `"Managed by Terraform."` | no |
| <a name="input_ostype"></a> [ostype](#input\_ostype) | OS type. Use 'cloud-init' for cloud-init templates | `string` | `"cloud-init"` | no |
| <a name="input_pool"></a> [pool](#input\_pool) | Destination Proxmox resource pool | `string` | `null` | no |
| <a name="input_scsihw"></a> [scsihw](#input\_scsihw) | SCSI controller model | `string` | `"virtio-scsi-pci"` | no |
| <a name="input_searchdomain"></a> [searchdomain](#input\_searchdomain) | Default DNS search domain suffix | `string` | `null` | no |
| <a name="input_serial0"></a> [serial0](#input\_serial0) | Serial device index for console access | `number` | `0` | no |
| <a name="input_size"></a> [size](#input\_size) | Boot disk size (e.g., 20G) | `string` | `null` | no |
| <a name="input_sockets"></a> [sockets](#input\_sockets) | Number of CPU sockets | `number` | `null` | no |
| <a name="input_sshkeys"></a> [sshkeys](#input\_sshkeys) | Newline-delimited SSH public keys for the cloud-init user | `string` | n/a | yes |
| <a name="input_storage"></a> [storage](#input\_storage) | Proxmox storage target for disks (e.g., local-lvm, nvme2-ceph) | `string` | n/a | yes |
| <a name="input_tag"></a> [tag](#input\_tag) | 802.1Q VLAN ID | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Comma-separated tags stored on the VM | `string` | `""` | no |
| <a name="input_target_node"></a> [target\_node](#input\_target\_node) | Preferred Proxmox node to place the VM | `string` | `null` | no |
| <a name="input_target_nodes"></a> [target\_nodes](#input\_target\_nodes) | List of Proxmox nodes eligible for placement | `list(string)` | `null` | no |
| <a name="input_vcpus"></a> [vcpus](#input\_vcpus) | Total virtual CPUs (threads) | `number` | `null` | no |
| <a name="input_vmid"></a> [vmid](#input\_vmid) | Proxmox VM ID. Use 0 to auto-assign the next available ID | `number` | `0` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | VM ID |
| <a name="output_vm_ip"></a> [vm\_ip](#output\_vm\_ip) | VM IPv4 Address |
| <a name="output_vm_memory"></a> [vm\_memory](#output\_vm\_memory) | VM Memory |
| <a name="output_vm_name"></a> [vm\_name](#output\_vm\_name) | VM Name |
| <a name="output_vm_nameserver"></a> [vm\_nameserver](#output\_vm\_nameserver) | VM Nameserver |
| <a name="output_vm_notes"></a> [vm\_notes](#output\_vm\_notes) | VM Notes |
| <a name="output_vm_tags"></a> [vm\_tags](#output\_vm\_tags) | VM Tags |
| <a name="output_vm_vcpus"></a> [vm\_vcpus](#output\_vm\_vcpus) | VM VCPUS |
<!-- END_TF_DOCS -->