# Multiple Networks and Disks — Reference Examples

Extended examples showing NICs, additional disks, ISO boot, and PXE boot.
For provider setup see the [Telmate/proxmox provider docs](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs).

---

## Multiple NICs with VLAN tagging

```hcl
module "multi_network_vm" {
  source = "github.com/valueiron/pvevm"

  name          = "multi-net-vm"
  vmid          = 200
  target_node   = "pve1"
  clone         = "ubuntu-24.04-template"
  storage       = "local-lvm"
  instance_size = "medium"

  networks = [
    { model = "virtio", bridge = "vmbr0", tag = 100 }, # Management VLAN
    { model = "virtio", bridge = "vmbr0", tag = 200 }, # Data VLAN
    { model = "virtio", bridge = "vmbr1", tag = 300, rate = 1000 }, # Storage VLAN
  ]

  ciuser     = var.ciuser
  cipassword = var.cipassword
  sshkeys    = var.sshkeys
}
```

---

## Multiple additional disks

```hcl
module "multi_disk_vm" {
  source = "github.com/valueiron/pvevm"

  name          = "storage-server"
  vmid          = 201
  target_node   = "pve2"
  clone         = "ubuntu-24.04-template"
  storage       = "local-lvm"
  instance_size = "large"

  # scsi0 = 40G boot disk (from large preset)
  # scsi1 = cloud-init disk (auto-configured)
  additional_disks = [
    { type = "scsi", slot = 2, storage = "nvme2-ceph", size = "100G" },
    { type = "scsi", slot = 3, storage = "nvme2-ceph", size = "500G" },
    { type = "scsi", slot = 4, storage = "local-lvm",  size = "200G" },
  ]

  bridge       = "vmbr0"
  tag          = 150
  ipconfig0    = "ip=172.22.150.201/24,gw=172.22.150.1"
  nameserver   = "1.1.1.1"
  searchdomain = "example.com"
  ciuser       = var.ciuser
  cipassword   = var.cipassword
  sshkeys      = var.sshkeys
}
```

---

## Multiple NICs and disks with custom CPU (database server)

```hcl
module "db_vm" {
  source = "github.com/valueiron/pvevm"

  name        = "database-server"
  vmid        = 202
  target_node = "pve1"
  clone       = "ubuntu-24.04-template"
  storage     = "nvme2-ceph"

  cpu    = { cores = 8, sockets = 2, vcores = 16 }
  memory = 65536 # 64 GiB

  networks = [
    { model = "virtio", bridge = "vmbr0", tag = 100 },                   # Management
    { model = "virtio", bridge = "vmbr0", tag = 500, rate = 10000, queues = 8 }, # DB cluster
  ]

  additional_disks = [
    { type = "scsi", slot = 2, storage = "nvme2-ceph", size = "500G" }, # Data
    { type = "scsi", slot = 3, storage = "nvme2-ceph", size = "200G" }, # Logs
    { type = "scsi", slot = 4, storage = "local-lvm",  size = "100G" }, # Scratch
  ]

  ipconfig0    = "ip=172.22.150.202/24,gw=172.22.150.1"
  nameserver   = "1.1.1.1"
  searchdomain = "example.com"
  ciuser       = var.ciuser
  cipassword   = var.cipassword
  sshkeys      = var.sshkeys
  tags         = "database,production"
}
```

---

## ISO boot

```hcl
module "iso_vm" {
  source = "github.com/valueiron/pvevm"

  name        = "iso-install-vm"
  vmid        = 204
  target_node = "pve1"
  storage     = "local-lvm"

  instance_size = "medium"
  iso           = "local:iso/ubuntu-24.04-server-amd64.iso"
  # boot defaults to "order=ide2;scsi0" when iso is set; override if needed
  ostype = "l26"

  bridge = "vmbr0"
  tag    = 150
  # cloud-init disk (scsi1) is automatically skipped when iso is set
}
```

---

## PXE boot

```hcl
module "pxe_vm" {
  source = "github.com/valueiron/pvevm"

  name        = "pxe-install-vm"
  vmid        = 205
  target_node = "pve2"
  storage     = "local-lvm"

  instance_size = "large"
  pxe           = true
  # boot defaults to "order=net0" when pxe=true; override if needed

  bridge = "vmbr0"
  tag    = 100
}
```

---

## Disk and NIC configuration reference

### `networks` object fields

| Field      | Type   | Default    | Description |
|------------|--------|------------|-------------|
| `model`    | string | `"virtio"` | NIC model (virtio, e1000, etc.) |
| `bridge`   | string | `"vmbr0"`  | Network bridge |
| `tag`      | number | null       | 802.1Q VLAN ID |
| `firewall` | bool   | null       | Enable Proxmox firewall on this NIC |
| `link_down`| bool   | null       | Force link down |
| `macaddr`  | string | null       | Static MAC address |
| `queues`   | number | null       | Number of queues (multi-queue virtio) |
| `rate`     | number | null       | Rate limit in MB/s |

### `additional_disks` object fields

Only `scsi` disk type is supported. Slots 0 and 1 are reserved (boot disk and cloud-init).

| Field     | Type   | Description |
|-----------|--------|-------------|
| `type`    | string | Must be `"scsi"` |
| `slot`    | number | SCSI slot index (2–5) |
| `storage` | string | Storage target (e.g., `"local-lvm"`, `"nvme2-ceph"`) |
| `size`    | string | Disk size (e.g., `"100G"`) |

### Boot order priority

1. Explicit `boot` value, if set
2. `iso` set → `order=ide2;scsi0`
3. `pxe = true` → `order=net0`
4. Neither → Proxmox default
