# Proxmox VM Terraform Module

A Terraform module for creating and managing Proxmox VMs using the [Telmate/proxmox](https://registry.terraform.io/providers/Telmate/proxmox) provider.

## Usage

### Clone from template

```hcl
module "vm" {
  source = "github.com/valueiron/pvevm"

  name        = "web-01"
  target_node = "pve-node-1"
  clone       = "ubuntu-24.04-template"
  storage     = "local-lvm"

  instance_size = "medium"

  ciuser    = "ubuntu"
  sshkeys   = file("~/.ssh/id_rsa.pub")
  ipconfig0 = "ip=192.168.10.10/24,gw=192.168.10.1"
}
```

### Multiple VMs with `for_each`

```hcl
locals {
  vms = {
    web1 = { name = "web-1", target_node = "pve-node-1", ipconfig0 = "ip=192.168.10.11/24,gw=192.168.10.1" }
    db1  = { name = "db-1",  target_node = "pve-node-2", ipconfig0 = "ip=192.168.10.21/24,gw=192.168.10.1" }
  }
}

module "vm" {
  source   = "github.com/valueiron/pvevm"
  for_each = local.vms

  name        = each.value.name
  target_node = each.value.target_node
  clone       = "ubuntu-24.04-template"
  storage     = "local-lvm"

  instance_size = "small"
  ipconfig0     = each.value.ipconfig0

  ciuser  = "ubuntu"
  sshkeys = file("~/.ssh/id_rsa.pub")
}

# Access outputs per VM key
output "vm_ids" {
  value = { for k, m in module.vm : k => m.vm_id }
}
```

### Multiple NICs and additional disks

```hcl
module "vm" {
  source = "github.com/valueiron/pvevm"

  name        = "storage-node"
  target_node = "pve-node-1"
  clone       = "ubuntu-24.04-template"
  storage     = "local-lvm"

  instance_size = "large"

  networks = [
    { model = "virtio", bridge = "vmbr0", tag = 100 },
    { model = "virtio", bridge = "vmbr0", tag = 200, rate = 1000 },
  ]

  additional_disks = [
    { type = "scsi", slot = 2, storage = "nvme2-ceph", size = "100G" },
    { type = "scsi", slot = 3, storage = "nvme2-ceph", size = "500G" },
  ]

  ciuser    = "ubuntu"
  sshkeys   = file("~/.ssh/id_rsa.pub")
  ipconfig0 = "ip=dhcp"
  ipconfig1 = "ip=dhcp"
}
```

### Boot from ISO

```hcl
module "vm" {
  source = "github.com/valueiron/pvevm"

  name        = "install-vm"
  target_node = "pve-node-1"
  storage     = "local-lvm"

  size   = "40G"
  iso    = "local:iso/ubuntu-24.04-server-amd64.iso"
  ostype = "l26"
}
```

### PXE boot

```hcl
module "vm" {
  source = "github.com/valueiron/pvevm"

  name        = "pxe-vm"
  target_node = "pve-node-1"
  storage     = "local-lvm"

  instance_size = "small"
  pxe           = true
  bridge        = "vmbr0"
  tag           = 100
}
```

## Instance sizes

| Size   | Memory  | Cores | Sockets | vCores | Disk |
|--------|---------|-------|---------|--------|------|
| xsmall | 2 GiB   | 1     | 1       | 1      | 10G  |
| small  | 4 GiB   | 2     | 1       | 2      | 12G  |
| medium | 8 GiB   | 4     | 1       | 4      | 20G  |
| large  | 16 GiB  | 8     | 1       | 8      | 40G  |
| xlarge | 32 GiB  | 10    | 1       | 10     | 60G  |

When `instance_size` is empty (the default), the `small` preset is used as the fallback. The `memory`, `size`, and `cpu` inputs always take precedence over the preset.

To add custom presets, pass a replacement map via `instance_sizes`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_vm_qemu.pvevm](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | VM name as it will appear in Proxmox | `string` | n/a | yes |
| <a name="input_storage"></a> [storage](#input\_storage) | Proxmox storage target for disks (e.g., local-lvm, nvme2-ceph) | `string` | n/a | yes |
| <a name="input_additional_disks"></a> [additional\_disks](#input\_additional\_disks) | Additional disks to attach beyond the scsi0 boot disk and cloud-init disk. Only 'scsi' type is supported. Slots 0 and 1 are reserved; use slots 2–5. | <pre>list(object({<br/>    type    = string<br/>    storage = string<br/>    size    = string<br/>    slot    = number<br/>  }))</pre> | `[]` | no |
| <a name="input_agent"></a> [agent](#input\_agent) | Enable QEMU Guest Agent (1 enabled, 0 disabled) | `number` | `1` | no |
| <a name="input_boot"></a> [boot](#input\_boot) | Boot order specification (e.g., `order=scsi0;net0`). Defaults to `order=ide2;scsi0` when ISO is set, `order=net0` when PXE is enabled. | `string` | `null` | no |
| <a name="input_bridge"></a> [bridge](#input\_bridge) | Network bridge for the default NIC (e.g., vmbr0). Ignored when `networks` is set. | `string` | `"vmbr0"` | no |
| <a name="input_cipassword"></a> [cipassword](#input\_cipassword) | Cloud-init user password. Not required when ISO is specified. | `string` | `null` | no |
| <a name="input_ciuser"></a> [ciuser](#input\_ciuser) | Cloud-init default user. Not required when ISO is specified. | `string` | `null` | no |
| <a name="input_clone"></a> [clone](#input\_clone) | Source template or VM name to clone. Not required when ISO is specified. | `string` | `null` | no |
| <a name="input_cores"></a> [cores](#input\_cores) | **DEPRECATED** — use the `cpu` block or `instance_size` instead. CPU cores per socket. | `number` | `null` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Explicit CPU configuration. Overrides `cores`, `sockets`, `vcpus`, and `instance_size`. | <pre>object({<br/>    cores   = number<br/>    sockets = number<br/>    vcores  = number<br/>  })</pre> | `null` | no |
| <a name="input_id"></a> [id](#input\_id) | NIC device ID/index for the default single-NIC configuration. Ignored when `networks` is set. | `number` | `0` | no |
| <a name="input_instance_size"></a> [instance\_size](#input\_instance\_size) | Predefined size preset (xsmall, small, medium, large, xlarge). Leave empty to use custom values; `small` is the fallback when empty. | `string` | `""` | no |
| <a name="input_instance_sizes"></a> [instance\_sizes](#input\_instance\_sizes) | Map of size presets defining memory, cores, sockets, vcores, and disk size. Override to replace or extend the built-in presets. | <pre>map(object({<br/>    memory  = number<br/>    cores   = number<br/>    sockets = number<br/>    vcores  = number<br/>    size    = string<br/>  }))</pre> | <pre>{<br/>  "large": {<br/>    "cores": 8,<br/>    "memory": 16384,<br/>    "size": "40G",<br/>    "sockets": 1,<br/>    "vcores": 8<br/>  },<br/>  "medium": {<br/>    "cores": 4,<br/>    "memory": 8192,<br/>    "size": "20G",<br/>    "sockets": 1,<br/>    "vcores": 4<br/>  },<br/>  "small": {<br/>    "cores": 2,<br/>    "memory": 4096,<br/>    "size": "12G",<br/>    "sockets": 1,<br/>    "vcores": 2<br/>  },<br/>  "xlarge": {<br/>    "cores": 10,<br/>    "memory": 32768,<br/>    "size": "60G",<br/>    "sockets": 1,<br/>    "vcores": 10<br/>  },<br/>  "xsmall": {<br/>    "cores": 1,<br/>    "memory": 2048,<br/>    "size": "10G",<br/>    "sockets": 1,<br/>    "vcores": 1<br/>  }<br/>}</pre> | no |
| <a name="input_ipconfig0"></a> [ipconfig0](#input\_ipconfig0) | Cloud-init IP config for NIC 0 (e.g., `ip=192.168.1.10/24,gw=192.168.1.1` or `ip=dhcp`). | `string` | `"ip=dhcp"` | no |
| <a name="input_ipconfig1"></a> [ipconfig1](#input\_ipconfig1) | Cloud-init IP config for NIC 1 (same format as ipconfig0). Cloud-init IP configuration is only supported for NIC indices 0–1. | `string` | `null` | no |
| <a name="input_iso"></a> [iso](#input\_iso) | ISO file in Proxmox storage format (e.g., `local:iso/ubuntu-22.04.iso`). Configures IDE2 as a CD-ROM and skips the cloud-init disk. | `string` | `null` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory allocated to the VM in MiB. Overrides `instance_size`. | `number` | `null` | no |
| <a name="input_model"></a> [model](#input\_model) | NIC model for the default NIC (e.g., virtio, e1000). Ignored when `networks` is set. | `string` | `"virtio"` | no |
| <a name="input_nameserver"></a> [nameserver](#input\_nameserver) | Default DNS server for the guest. | `string` | `null` | no |
| <a name="input_networks"></a> [networks](#input\_networks) | List of NICs. When non-empty, overrides the single-NIC defaults (`bridge`, `model`, `tag`, `id`). | <pre>list(object({<br/>    id        = optional(number, 0)<br/>    model     = optional(string, "virtio")<br/>    bridge    = optional(string, "vmbr0")<br/>    tag       = optional(number)<br/>    firewall  = optional(bool)<br/>    link_down = optional(bool)<br/>    macaddr   = optional(string)<br/>    queues    = optional(number)<br/>    rate      = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_notes"></a> [notes](#input\_notes) | VM notes displayed in the Proxmox UI (maps to the provider's `description` attribute). | `string` | `"Managed by Terraform."` | no |
| <a name="input_ostype"></a> [ostype](#input\_ostype) | OS type passed to the provider's `os_type` attribute. Use `cloud-init` for cloud-init templates. Other accepted values: `ubuntu`, `centos`, `fedora`, `opensuse`, `arch`, `debian`, `alpine`, `solaris`, `l24`, `l26`, `other`, `wxp`, `w2k`, `w2k3`, `w2k8`, `wvista`, `win7`, `win8`, `win10`, `win11`. | `string` | `"cloud-init"` | no |
| <a name="input_pool"></a> [pool](#input\_pool) | Destination Proxmox resource pool. | `string` | `null` | no |
| <a name="input_pxe"></a> [pxe](#input\_pxe) | Enable PXE boot. Sets boot order to `order=net0` when `boot` is not explicitly specified. | `bool` | `null` | no |
| <a name="input_scsihw"></a> [scsihw](#input\_scsihw) | SCSI controller model. | `string` | `"virtio-scsi-pci"` | no |
| <a name="input_searchdomain"></a> [searchdomain](#input\_searchdomain) | Default DNS search domain suffix. | `string` | `null` | no |
| <a name="input_serial0"></a> [serial0](#input\_serial0) | Serial device index for console access. | `number` | `0` | no |
| <a name="input_serial0_type"></a> [serial0\_type](#input\_serial0\_type) | Serial device type (`socket` for a Unix socket, or a host device path like `/dev/ttyS0`). | `string` | `"socket"` | no |
| <a name="input_size"></a> [size](#input\_size) | Boot disk size (e.g., `20G`). Overrides `instance_size`. | `string` | `null` | no |
| <a name="input_skip_ipv6"></a> [skip\_ipv6](#input\_skip\_ipv6) | Disable IPv6 address reporting from the QEMU agent. | `bool` | `true` | no |
| <a name="input_sockets"></a> [sockets](#input\_sockets) | **DEPRECATED** — use the `cpu` block or `instance_size` instead. Number of CPU sockets. | `number` | `null` | no |
| <a name="input_sshkeys"></a> [sshkeys](#input\_sshkeys) | Newline-delimited SSH public keys for the cloud-init user. Not required when ISO is specified. | `string` | `null` | no |
| <a name="input_tag"></a> [tag](#input\_tag) | 802.1Q VLAN ID for the default NIC. Ignored when `networks` is set. | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Comma-separated tags stored on the VM. | `string` | `""` | no |
| <a name="input_target_node"></a> [target\_node](#input\_target\_node) | Proxmox node to place the VM on. Exactly one of `target_node` or `target_nodes` must be set. | `string` | `null` | no |
| <a name="input_target_nodes"></a> [target\_nodes](#input\_target\_nodes) | List of Proxmox nodes eligible for placement. Exactly one of `target_node` or `target_nodes` must be set. | `list(string)` | `null` | no |
| <a name="input_vcpus"></a> [vcpus](#input\_vcpus) | **DEPRECATED** — use the `cpu` block or `instance_size` instead. Total virtual CPUs (threads). | `number` | `null` | no |
| <a name="input_vmid"></a> [vmid](#input\_vmid) | Proxmox VM ID. Set to `0` to auto-assign the next available ID. | `number` | `0` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_cores"></a> [vm\_cores](#output\_vm\_cores) | CPU cores per socket as applied by the provider |
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | VM ID, parsed from the resource ID to handle auto-assigned VMIDs |
| <a name="output_vm_ip"></a> [vm\_ip](#output\_vm\_ip) | Primary IPv4 address reported by the QEMU agent |
| <a name="output_vm_memory"></a> [vm\_memory](#output\_vm\_memory) | Memory allocated to the VM in MiB |
| <a name="output_vm_name"></a> [vm\_name](#output\_vm\_name) | VM name as it appears in Proxmox |
| <a name="output_vm_nameserver"></a> [vm\_nameserver](#output\_vm\_nameserver) | DNS nameserver configured on the VM |
| <a name="output_vm_notes"></a> [vm\_notes](#output\_vm\_notes) | VM notes as stored in Proxmox |
| <a name="output_vm_sockets"></a> [vm\_sockets](#output\_vm\_sockets) | CPU sockets as applied by the provider |
| <a name="output_vm_tags"></a> [vm\_tags](#output\_vm\_tags) | Tags stored on the VM |
| <a name="output_vm_vcpus"></a> [vm\_vcpus](#output\_vm\_vcpus) | vCPUs (vcores) as applied by the provider |
<!-- END_TF_DOCS -->
