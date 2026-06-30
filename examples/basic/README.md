# Example: Basic

Clones a single VM from a cloud-init template using a predefined `medium` instance size.

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
- Cloud-init user `ubuntu` with the provided password and SSH key
- Single NIC on `vmbr0` with DHCP
