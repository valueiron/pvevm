output "vm_ip" {
  description = "Primary IPv4 address reported by the QEMU agent"
  value       = proxmox_vm_qemu.pvevm.default_ipv4_address
}

output "vm_nameserver" {
  description = "DNS nameserver configured on the VM"
  value       = proxmox_vm_qemu.pvevm.nameserver
}

output "vm_name" {
  description = "VM name as it appears in Proxmox"
  value       = proxmox_vm_qemu.pvevm.name
}

output "vm_id" {
  description = "VM ID, parsed from the resource ID to handle auto-assigned VMIDs"
  value       = tonumber(element(split("/", proxmox_vm_qemu.pvevm.id), 2))
}

output "vm_vcpus" {
  description = "vCPUs (vcores) as applied by the provider"
  value       = proxmox_vm_qemu.pvevm.cpu[0].vcores
}

output "vm_cores" {
  description = "CPU cores per socket as applied by the provider"
  value       = proxmox_vm_qemu.pvevm.cpu[0].cores
}

output "vm_sockets" {
  description = "CPU sockets as applied by the provider"
  value       = proxmox_vm_qemu.pvevm.cpu[0].sockets
}

output "vm_memory" {
  description = "Memory allocated to the VM in MiB"
  value       = proxmox_vm_qemu.pvevm.memory
}

output "vm_notes" {
  description = "VM notes as stored in Proxmox"
  value       = proxmox_vm_qemu.pvevm.description
}

output "vm_tags" {
  description = "Tags stored on the VM"
  value       = proxmox_vm_qemu.pvevm.tags
}
