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
| <a name="input_additional_disks"></a> [additional\_disks](#input\_additional\_disks) | List of additional disk configurations beyond the primary disk and cloudinit disk. Only 'storage' and 'size' are supported in v3.0.2-rc03. | <pre>list(object({<br/>    type    = string # scsi, sata, virtio, ide<br/>    storage = string # Storage location (e.g., "local-lvm", "nvme2-ceph")<br/>    size    = string # Disk size (e.g., "10G", "100G")<br/>    slot    = number # Disk slot number: scsi2-scsi5 (slots 0-1 reserved)<br/>  }))</pre> | `[]` | no |
| <a name="input_agent"></a> [agent](#input\_agent) | Qemu Guest Agent Enabled or not enabled=1 | `number` | `1` | no |
| <a name="input_bridge"></a> [bridge](#input\_bridge) | Map of tags to add to the VM. Stored as JSON in the Notes field in Proxmox. | `string` | `"vmbr0"` | no |
| <a name="input_cipassword"></a> [cipassword](#input\_cipassword) | Override the default cloud-init user's password | `string` | n/a | yes |
| <a name="input_ciuser"></a> [ciuser](#input\_ciuser) | Override the default cloud-init user for provisioning | `string` | n/a | yes |
| <a name="input_clone"></a> [clone](#input\_clone) | The base VM from which to clone to create the new VM | `string` | n/a | yes |
| <a name="input_connection"></a> [connection](#input\_connection) | Provisioner connection settings | `map(string)` | <pre>{<br/>  "agent": true,<br/>  "type": "ssh"<br/>}</pre> | no |
| <a name="input_cores"></a> [cores](#input\_cores) | The number of CPU cores per CPU socket to allocate to the VM | `number` | `null` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | CPU configuration block | <pre>object({<br/>    cores   = number<br/>    sockets = number<br/>    vcores  = number<br/>  })</pre> | `null` | no |
| <a name="input_disks"></a> [disks](#input\_disks) | DEPRECATED: Use additional\_disks instead. VM disk config | `list(map(string))` | <pre>[<br/>  {}<br/>]</pre> | no |
| <a name="input_gateway"></a> [gateway](#input\_gateway) | Gateway IP Address | `string` | `""` | no |
| <a name="input_id"></a> [id](#input\_id) | New required field proxmox | `number` | `0` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Instance Count | `number` | `1` | no |
| <a name="input_instance_size"></a> [instance\_size](#input\_instance\_size) | The size of the instance (small, medium, large). If empty, custom values must be provided. | `string` | `""` | no |
| <a name="input_instance_sizes"></a> [instance\_sizes](#input\_instance\_sizes) | Map of instance sizes with predefined settings | <pre>map(object({<br/>    memory  = number<br/>    cores   = number<br/>    sockets = number<br/>    vcores  = number<br/>    size    = string<br/>  }))</pre> | <pre>{<br/>  "large": {<br/>    "cores": 8,<br/>    "memory": 16384,<br/>    "size": "40G",<br/>    "sockets": 1,<br/>    "vcores": 8<br/>  },<br/>  "medium": {<br/>    "cores": 4,<br/>    "memory": 8192,<br/>    "size": "20G",<br/>    "sockets": 1,<br/>    "vcores": 4<br/>  },<br/>  "small": {<br/>    "cores": 2,<br/>    "memory": 4096,<br/>    "size": "12G",<br/>    "sockets": 1,<br/>    "vcores": 2<br/>  },<br/>  "xlarge": {<br/>    "cores": 10,<br/>    "memory": 32768,<br/>    "size": "60G",<br/>    "sockets": 1,<br/>    "vcores": 10<br/>  },<br/>  "xsmall": {<br/>    "cores": 1,<br/>    "memory": 2048,<br/>    "size": "10G",<br/>    "sockets": 1,<br/>    "vcores": 1<br/>  }<br/>}</pre> | no |
| <a name="input_ip_addresses"></a> [ip\_addresses](#input\_ip\_addresses) | List of IP addresses with cidr notation | `list(string)` | `[]` | no |
| <a name="input_ipconfig0"></a> [ipconfig0](#input\_ipconfig0) | The first IP address to assign to the guest. Format: [gw=<GatewayIPv4>] [,gw6=<GatewayIPv6>] [,ip=<IPv4Format/CIDR>] [,ip6=<IPv6Format/CIDR>] | `string` | `"ip=dhcp"` | no |
| <a name="input_ipconfig1"></a> [ipconfig1](#input\_ipconfig1) | The second IP address to assign to the guest. Same format as ipconfig0 | `string` | `null` | no |
| <a name="input_ipconfig2"></a> [ipconfig2](#input\_ipconfig2) | The third IP address to assign to the guest. Same format as ipconfig0 | `string` | `null` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount of memory to allocate to the VM in Megabytes | `number` | `null` | no |
| <a name="input_model"></a> [model](#input\_model) | Network Model | `string` | `"virtio"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the VM within Proxmox | `string` | n/a | yes |
| <a name="input_nameserver"></a> [nameserver](#input\_nameserver) | Sets default DNS server for guest | `string` | `null` | no |
| <a name="input_networks"></a> [networks](#input\_networks) | List of network configurations for the VM. Leave empty to use single network config (bridge, model, tag variables). | <pre>list(object({<br/>    id        = optional(number, 0)<br/>    model     = optional(string, "virtio")<br/>    bridge    = optional(string, "vmbr0")<br/>    tag       = optional(number)<br/>    firewall  = optional(bool)<br/>    link_down = optional(bool)<br/>    macaddr   = optional(string)<br/>    queues    = optional(number)<br/>    rate      = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_notes"></a> [notes](#input\_notes) | VM notes field that maps to desc | `string` | `"Managed by Terraform."` | no |
| <a name="input_ostype"></a> [ostype](#input\_ostype) | The OS Type | `string` | `"cloud-init"` | no |
| <a name="input_pool"></a> [pool](#input\_pool) | The destination resource pool for the new VM | `string` | `null` | no |
| <a name="input_proxmox_api_token_id"></a> [proxmox\_api\_token\_id](#input\_proxmox\_api\_token\_id) | API Token | `string` | n/a | yes |
| <a name="input_proxmox_api_token_secret"></a> [proxmox\_api\_token\_secret](#input\_proxmox\_api\_token\_secret) | API Secret | `string` | n/a | yes |
| <a name="input_proxmox_api_url"></a> [proxmox\_api\_url](#input\_proxmox\_api\_url) | Full Proxmox API URL | `string` | n/a | yes |
| <a name="input_proxmox_tls_insecure"></a> [proxmox\_tls\_insecure](#input\_proxmox\_tls\_insecure) | Allow Insecure TLS | `bool` | `true` | no |
| <a name="input_scsihw"></a> [scsihw](#input\_scsihw) | scsi hardware type | `string` | `"virtio-scsi-pci"` | no |
| <a name="input_searchdomain"></a> [searchdomain](#input\_searchdomain) | Sets default DNS search domain suffix | `string` | `null` | no |
| <a name="input_serial0"></a> [serial0](#input\_serial0) | serial device in order for console device to work | `number` | `0` | no |
| <a name="input_size"></a> [size](#input\_size) | Disk Size | `string` | `null` | no |
| <a name="input_sockets"></a> [sockets](#input\_sockets) | The number of CPU sockets to allocate to the VM | `number` | `null` | no |
| <a name="input_sshkeys"></a> [sshkeys](#input\_sshkeys) | Newline delimited list of SSH public keys to add to authorized keys file for the cloud-init user | `string` | n/a | yes |
| <a name="input_storage"></a> [storage](#input\_storage) | Disk Storage Location | `string` | n/a | yes |
| <a name="input_tag"></a> [tag](#input\_tag) | Vlan ID | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | tags comma seperated | `string` | `""` | no |
| <a name="input_target_node"></a> [target\_node](#input\_target\_node) | The name of the Proxmox Node on which to place the VM | `string` | `null` | no |
| <a name="input_target_nodes"></a> [target\_nodes](#input\_target\_nodes) | The name of the Proxmox Node on which to place the VM | `list(string)` | `null` | no |
| <a name="input_vcpus"></a> [vcpus](#input\_vcpus) | The number of vCPU  to allocate to the VM | `number` | `null` | no |
| <a name="input_vmid"></a> [vmid](#input\_vmid) | The vm id of the VM within Proxmox. Default is next available | `number` | `0` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | VM IDS |
| <a name="output_vm_ip"></a> [vm\_ip](#output\_vm\_ip) | VM IP Addresses |
| <a name="output_vm_memory"></a> [vm\_memory](#output\_vm\_memory) | VM Memory |
| <a name="output_vm_name"></a> [vm\_name](#output\_vm\_name) | VM NAMES |
| <a name="output_vm_nameserver"></a> [vm\_nameserver](#output\_vm\_nameserver) | VM Nameservers |
| <a name="output_vm_notes"></a> [vm\_notes](#output\_vm\_notes) | VM Notes |
| <a name="output_vm_tags"></a> [vm\_tags](#output\_vm\_tags) | VM Tags |
| <a name="output_vm_vcpus"></a> [vm\_vcpus](#output\_vm\_vcpus) | VM VCPUS |
<!-- END_TF_DOCS -->