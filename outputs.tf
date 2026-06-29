output "vm_ip" {
  description = "VM IPv4 Address"
  value       = proxmox_vm_qemu.pvevm.default_ipv4_address
}

output "vm_nameserver" {
  description = "VM Nameserver"
  value       = proxmox_vm_qemu.pvevm.nameserver
}

output "vm_name" {
  description = "VM Name"
  value       = proxmox_vm_qemu.pvevm.name
}

output "vm_id" {
  description = "VM ID (parsed from resource ID to handle auto-assigned VMIDs)"
  value       = tonumber(element(split("/", proxmox_vm_qemu.pvevm.id), 2))
}

output "vm_vcpus" {
  description = "VM vCPUs (vcores) as applied by the provider"
  value       = proxmox_vm_qemu.pvevm.cpu[0].vcores
}

output "vm_cores" {
  description = "VM CPU cores per socket as applied by the provider"
  value       = proxmox_vm_qemu.pvevm.cpu[0].cores
}

output "vm_sockets" {
  description = "VM CPU sockets as applied by the provider"
  value       = proxmox_vm_qemu.pvevm.cpu[0].sockets
}

output "vm_memory" {
  description = "VM Memory"
  value       = proxmox_vm_qemu.pvevm.memory
}

output "vm_notes" {
  description = "VM Notes"
  value       = proxmox_vm_qemu.pvevm.description
}

output "vm_tags" {
  description = "VM Tags"
  value       = proxmox_vm_qemu.pvevm.tags
}
