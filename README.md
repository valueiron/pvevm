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

### v3.0.2-rc03 Upgrade

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