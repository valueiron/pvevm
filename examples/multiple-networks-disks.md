# Multiple Networks and Disks Example

This example demonstrates how to use the module with multiple network interfaces and additional disks.

## Example 1: Multiple Network Interfaces

```hcl
module "multi_network_vm" {
  source = "github.com/valueiron/pvevm.git?ref=feature/expansion"
  
  proxmox_api_url          = var.pm_api_url
  proxmox_api_token_id     = var.pm_api_token_id
  proxmox_api_token_secret = var.pm_api_token_secret
  
  name         = "multi-net-vm"
  vmid         = 200
  target_node  = "pve1"
  clone        = "ubuntu2404-template"
  storage      = "local-lvm"
  instance_size = "medium"
  
  # Multiple network configurations
  networks = [
    {
      id     = 0
      model  = "virtio"
      bridge = "vmbr0"
      tag    = 100      # Management VLAN
    },
    {
      id     = 1
      model  = "virtio"
      bridge = "vmbr0"
      tag    = 200      # Data VLAN
    },
    {
      id     = 2
      model  = "virtio"
      bridge = "vmbr1"
      tag    = 300      # Storage VLAN
      rate   = 1000     # Rate limit in MB/s
    }
  ]
  
  # Cloud-init configuration
  ciuser     = var.ciuser
  cipassword = var.cipassword
  sshkeys    = var.sshkeys
}
```

## Example 2: Multiple Disks

```hcl
module "multi_disk_vm" {
  source = "github.com/valueiron/pvevm.git?ref=feature/expansion"
  
  proxmox_api_url          = var.pm_api_url
  proxmox_api_token_id     = var.pm_api_token_id
  proxmox_api_token_secret = var.pm_api_token_secret
  
  name         = "storage-server"
  vmid         = 201
  target_node  = "pve2"
  clone        = "ubuntu2404-template"
  storage      = "local-lvm"
  instance_size = "large"
  
  # Primary disk is configured via instance_size (40GB for large)
  # scsi0 = primary disk (from template)
  # scsi1 = cloudinit disk (auto-configured)
  
  # Additional disks
  additional_disks = [
    {
      type    = "scsi"
      slot    = 2
      storage = "nvme2-ceph"
      size    = "100G"
    },
    {
      type    = "scsi"
      slot    = 3
      storage = "nvme2-ceph"
      size    = "500G"
    },
    {
      type    = "scsi"
      slot    = 4
      storage = "local-lvm"
      size    = "200G"
    }
  ]
  
  # Network configuration
  bridge = "vmbr0"
  tag    = 150
  
  # Cloud-init configuration
  ipconfig0    = "ip=172.22.150.201/24,gw=172.22.150.1"
  nameserver   = "1.1.1.1"
  searchdomain = "valueironhomelab.com"
  ciuser       = var.ciuser
  cipassword   = var.cipassword
  sshkeys      = var.sshkeys
}
```

## Example 3: Combined - Multiple Networks and Disks

```hcl
module "advanced_vm" {
  source = "github.com/valueiron/pvevm.git?ref=feature/expansion"
  
  proxmox_api_url          = var.pm_api_url
  proxmox_api_token_id     = var.pm_api_token_id
  proxmox_api_token_secret = var.pm_api_token_secret
  
  name         = "database-server"
  vmid         = 202
  target_node  = "pve1"
  clone        = "ubuntu2404-template"
  storage      = "nvme2-ceph"
  
  # Custom CPU and memory
  cpu = {
    cores   = 8
    sockets = 2
    vcores  = 16
  }
  memory = 65536  # 64GB
  
  # Multiple network interfaces
  networks = [
    {
      id     = 0
      model  = "virtio"
      bridge = "vmbr0"
      tag    = 100      # Management network
    },
    {
      id     = 1
      model  = "virtio"
      bridge = "vmbr0"
      tag    = 500      # Database cluster network
      rate   = 10000    # 10Gb/s
      queues = 8
    }
  ]
  
  # Multiple disks for database storage
  additional_disks = [
    {
      type    = "scsi"
      slot    = 2
      storage = "nvme2-ceph"
      size    = "500G"  # Database data
    },
    {
      type    = "scsi"
      slot    = 3
      storage = "nvme2-ceph"
      size    = "200G"  # Database logs
    },
    {
      type    = "scsi"
      slot    = 4
      storage = "local-lvm"
      size    = "100G"  # Temporary/scratch space
    }
  ]
  
  # Cloud-init configuration
  ipconfig0    = "ip=172.22.150.202/24,gw=172.22.150.1"
  nameserver   = "1.1.1.1"
  searchdomain = "valueironhomelab.com"
  ciuser       = var.ciuser
  cipassword   = var.cipassword
  sshkeys      = var.sshkeys
  tags         = "database,production"
}
```

## Example 4: Backward Compatibility - Single Network/Disk (Original Syntax)

```hcl
module "simple_vm" {
  source = "github.com/valueiron/pvevm.git?ref=feature/expansion"
  
  proxmox_api_url          = var.pm_api_url
  proxmox_api_token_id     = var.pm_api_token_id
  proxmox_api_token_secret = var.pm_api_token_secret
  
  name         = "simple-vm"
  vmid         = 203
  target_node  = "pve2"
  clone        = "ubuntu2404-template"
  storage      = "local-lvm"
  instance_size = "small"
  
  # Single network using original variables
  bridge = "vmbr0"
  model  = "virtio"
  tag    = 150
  
  # Single disk using instance_size
  # No additional_disks specified
  
  # Cloud-init configuration
  ipconfig0    = "ip=172.22.150.203/24,gw=172.22.150.1"
  nameserver   = "1.1.1.1"
  searchdomain = "valueironhomelab.com"
  ciuser       = var.ciuser
  cipassword   = var.cipassword
  sshkeys      = var.sshkeys
}
```

## Network Configuration Options

| Parameter | Description | Type | Default |
|-----------|-------------|------|---------|
| id | Network interface ID | number | 0 |
| model | Network model (virtio, e1000, etc) | string | "virtio" |
| bridge | Network bridge | string | "vmbr0" |
| tag | VLAN tag | number | null |
| firewall | Enable firewall | bool | null |
| link_down | Set link down | bool | null |
| macaddr | MAC address | string | null |
| queues | Number of queues | number | null |
| rate | Rate limit in MB/s | number | null |

## Disk Configuration Options

| Parameter | Description | Type | Default |
|-----------|-------------|------|---------|
| type | Disk type (scsi, sata, virtio, ide) | string | **required** |
| slot | Disk slot number (2-5 for SCSI) | number | **required** |
| storage | Storage location | string | **required** |
| size | Disk size (e.g., "100G") | string | **required** |

**Note:** In Proxmox provider v3.0.2-rc03, only `type`, `slot`, `storage`, and `size` are supported for additional disks. Advanced options like `ssd`, `cache`, `iothread`, etc. are not available in the disk block.

## Important Notes

1. **Disk Slots**: 
   - scsi0 is reserved for the primary disk (from template/instance_size)
   - scsi1 is reserved for cloudinit
   - scsi2-scsi5 are available for additional disks

2. **Backward Compatibility**: 
   - If you don't specify `networks`, the module uses the original single network variables (`bridge`, `model`, `tag`)
   - If you don't specify `additional_disks`, only the primary disk and cloudinit disk are created

3. **Network Fallback**: 
   - Leave `networks = []` to use the original single network configuration
   - Specify `networks` to override and use multiple networks

4. **Performance Tips**:
   - Set appropriate `rate` limits on network interfaces if needed
   - Use multiple network interfaces for different traffic types (management, data, storage)
   - Choose appropriate storage backends (nvme2-ceph for performance, local-lvm for local storage)

