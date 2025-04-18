output "vm_ip" {
  description = "VM IP Addresses"
  value       = [for vm in proxmox_vm_qemu.pvevm : vm.default_ipv4_address]
}

output "vm_nameserver" {
  description = "VM Nameservers"
  value       = [for vm in proxmox_vm_qemu.pvevm : vm.nameserver]
}

output "vm_name" {
  description = "VM NAMES"
  value       = [for vm in proxmox_vm_qemu.pvevm : vm.name]
}

output "vm_id" {
  description = "VM IDS"
  value       = [for vm in proxmox_vm_qemu.pvevm : vm.vmid]
}

output "vm_vcpus" {
  description = "VM VCPUS"
  value       = [for vm in proxmox_vm_qemu.pvevm : vm.vcpus]
}

output "vm_memory" {
  description = "VM Memory"
  value       = [for vm in proxmox_vm_qemu.pvevm : vm.memory]
}

output "vm_notes" {
  description = "VM Notes"
  value       = [for vm in proxmox_vm_qemu.pvevm : vm.desc]
}

output "vm_tags" {
  description = "VM Tags"
  value       = [for vm in proxmox_vm_qemu.pvevm : vm.tags]
}
