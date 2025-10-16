# Proxmox VM Module Examples

This module has been updated to use Proxmox provider v3.0.2-rc03 with improved syntax.

## New in feature/expansion Branch

The `feature/expansion` branch adds support for:
- **Multiple Network Interfaces**: Configure VMs with multiple NICs on different VLANs/bridges
- **Additional Disks**: Add extra disks beyond the primary and cloudinit disks
- See [multiple-networks-disks.md](./multiple-networks-disks.md) for detailed examples

## Basic Usage

```hcl
module "example_vm" {
  source = "../../modules/pvevm"
  
  name         = "example-vm"
  target_node  = "pve-node-1"
  clone        = "ubuntu-template"
  storage      = "local-lvm"
  
  # Using predefined instance size
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

## Advanced Usage with Custom CPU Configuration

```hcl
module "custom_vm" {
  source = "../../modules/pvevm"
  
  name         = "custom-vm"
  target_node  = "pve-node-2"
  clone        = "debian-template"
  storage      = "local-lvm"
  
  # Custom CPU configuration using the new cpu block
  cpu = {
    cores   = 8
    sockets = 2
    vcores  = 16
  }
  
  # Custom memory
  memory = 32768
  
  # Custom disk size
  size = "100G"
  
  # Network configuration
  bridge = "vmbr0"
  model  = "virtio"
  
  # Cloud-init configuration
  ciuser     = "debian"
  cipassword = "your-password"
  sshkeys    = file("~/.ssh/id_rsa.pub")
}
```

## Multiple Instances

```hcl
module "cluster_vms" {
  source = "../../modules/pvevm"
  
  name           = "cluster-node"
  instance_count = 3
  target_node    = "pve-node-1"
  clone          = "ubuntu-template"
  storage        = "local-lvm"
  
  # All instances will use the same configuration
  instance_size = "large"
  
  # Network configuration
  bridge = "vmbr0"
  model  = "virtio"
  
  # Cloud-init configuration
  ciuser     = "ubuntu"
  cipassword = "your-password"
  sshkeys    = file("~/.ssh/id_rsa.pub")
}
```

## Migration from Old Syntax

### Before (Provider v3.0.1-rc8 and earlier):
```hcl
module "old_vm" {
  source = "../../modules/pvevm"
  
  name     = "old-vm"
  cores    = 4
  sockets  = 1
  vcpus    = 4
  memory   = 8192
  # ... other configuration
}
```

### After (Provider v3.0.2-rc03):
```hcl
module "new_vm" {
  source = "../../modules/pvevm"
  
  name = "new-vm"
  
  # Option 1: Use predefined instance size
  instance_size = "medium"
  
  # Option 2: Use custom CPU configuration
  cpu = {
    cores   = 4
    sockets = 1
    vcores  = 4
  }
  
  memory = 8192
  # ... other configuration
}
```

## Key Changes in v3.0.2-rc03

1. **Provider Version**: Updated from `3.0.1-rc8` to `3.0.2-rc03`
2. **Description Field**: `desc` parameter changed to `description`
3. **CPU Configuration**: Individual `cores`, `sockets`, and `vcpus` parameters replaced with a `cpu` block containing:
   - `cores`: Number of CPU cores per socket
   - `sockets`: Number of CPU sockets
   - `vcores`: Total number of virtual CPUs
4. **Backward Compatibility**: The module still supports the old individual parameters for backward compatibility

## Outputs

The module provides the following outputs:

- `vm_ip`: List of VM IP addresses
- `vm_nameserver`: List of VM nameservers
- `vm_name`: List of VM names
- `vm_id`: List of VM IDs
- `vm_vcpus`: List of VM vCPU counts
- `vm_memory`: List of VM memory allocations
- `vm_notes`: List of VM descriptions/notes
- `vm_tags`: List of VM tags
