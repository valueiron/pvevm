# Example: Multi-Network

Clones a VM with two tagged NICs and one additional 100 GB SCSI data disk.

## Usage

```shell
terraform init
terraform apply \
  -var="cipassword=<password>" \
  -var='sshkeys=<public-key>'
```

## What this creates

- One `proxmox_vm_qemu` VM cloned from `ubuntu-template` on `pve-node-1`
- 8 GiB RAM, 4 cores, 20 GB boot disk (`medium` preset)
- NIC 0: `vmbr0`, VLAN 100
- NIC 1: `vmbr0`, VLAN 200, 1000 MB/s rate limit
- Additional disk: 100 GB on `local-lvm` at scsi2
- Cloud-init user `ubuntu` with DHCP on NIC 0
