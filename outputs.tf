output "vm_ip" {
  description = "List of VM IP addresses"
  value       = [for vm in proxmox_vm_qemu.pvevm : vm.default_ipv4_address]
}

output "vm_name" {
  description = "List of VM names"
  value       = [for vm in proxmox_vm_qemu.pvevm : vm.name]
}

output "vm_id" {
  description = "List of VM IDs"
  value       = [for vm in proxmox_vm_qemu.pvevm : vm.vmid]
}
