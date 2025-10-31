#####################################################
# Module Inputs (single-VM; use for_each at call site)
#####################################################

#####################################################
# VM QEMU Resource
#####################################################
variable "name" {
  description = "VM name as it will appear in Proxmox"
  type        = string
}

variable "vmid" {
  description = "Proxmox VM ID. Use 0 to auto-assign the next available ID"
  type        = number
  default     = 0

  validation {
    condition     = var.vmid == 0 || (var.vmid >= 100 && var.vmid <= 999999999)
    error_message = "vmid must be 0 (for auto) or between 100 and 999999999."
  }
}

variable "notes" {
  description = "Proxmox VM description/notes"
  type        = string
  default     = "Managed by Terraform."
}

variable "target_node" {
  description = "Preferred Proxmox node to place the VM"
  type        = string
  default     = null
}

variable "target_nodes" {
  description = "List of Proxmox nodes eligible for placement"
  type        = list(string)
  default     = null
}

variable "clone" {
  description = "Source template or VM name to clone"
  type        = string
}

variable "memory" {
  description = "Memory allocated to the VM in MiB"
  type        = number
  default     = null
}

variable "scsihw" {
  description = "SCSI controller model"
  type        = string
  default     = "virtio-scsi-pci"
}

variable "cores" {
  description = "CPU cores per socket"
  type        = number
  default     = null
}

variable "sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = null
}

variable "vcpus" {
  description = "Total virtual CPUs (threads)"
  type        = number
  default     = null
}

variable "agent" {
  description = "Enable QEMU Guest Agent (1 enabled, 0 disabled)"
  type        = number
  default     = 1
}

variable "serial0" {
  description = "Serial device index for console access"
  type        = number
  default     = 0
}

variable "tags" {
  description = "Comma-separated tags stored on the VM"
  type        = string
  default     = ""
}

############################## NETWORK
variable "bridge" {
  description = "Network bridge to attach NICs to (e.g., vmbr0)"
  type        = string
  default     = "vmbr0"
}

variable "id" {
  description = "NIC device ID/index as required by the provider"
  type        = number
  default     = 0
}

variable "model" {
  description = "NIC model (e.g., virtio, e1000)"
  type        = string
  default     = "virtio"
}

variable "tag" {
  description = "802.1Q VLAN ID"
  type        = number
  default     = null
}

// Removed legacy ip_addresses/gateway; use ipconfig* directly per VM

######################### STORAGE
variable "storage" {
  description = "Proxmox storage target for disks (e.g., local-lvm, nvme2-ceph)"
  type        = string
}

variable "size" {
  description = "Boot disk size (e.g., 20G)"
  type        = string
  default     = null
}


################################# Multiple Network and Disk Support
variable "networks" {
  description = "Optional NIC list. If empty, a single NIC is built from bridge/model/tag"
  type = list(object({
    id        = optional(number, 0)
    model     = optional(string, "virtio")
    bridge    = optional(string, "vmbr0")
    tag       = optional(number)
    firewall  = optional(bool)
    link_down = optional(bool)
    macaddr   = optional(string)
    queues    = optional(number)
    rate      = optional(number)
  }))
  default = []
}

variable "additional_disks" {
  description = "Additional disks to attach (beyond scsi0 boot and cloud-init)"
  type = list(object({
    type    = string # scsi, sata, virtio, ide
    storage = string # e.g., "local-lvm", "nvme2-ceph"
    size    = string # e.g., "10G", "100G"
    slot    = number # scsi2–scsi5 (slots 0–1 reserved)
  }))
  default = []
}

// Removed unused connection settings

variable "pool" {
  description = "Destination Proxmox resource pool"
  type        = string
  default     = null
}

// Removed deprecated disks and legacy instance_count (module now single instance)

#####################################################
# Cloud-Init
#####################################################
variable "ostype" {
  description = "OS type. Use 'cloud-init' for cloud-init templates"
  type        = string
  default     = "cloud-init"
}

variable "ciuser" {
  description = "Cloud-init default user"
  type        = string
}

variable "cipassword" {
  description = "Cloud-init user password"
  type        = string
  sensitive   = true
}

variable "searchdomain" {
  description = "Default DNS search domain suffix"
  type        = string
  default     = null
}

variable "nameserver" {
  description = "Default DNS server for the guest"
  type        = string
  default     = null
}

variable "sshkeys" {
  description = "Newline-delimited SSH public keys for the cloud-init user"
  type        = string
}

variable "ipconfig0" {
  description = "Cloud-init IP config for NIC 0 (e.g., ip=192.168.1.10/24,gw=192.168.1.1)"
  type        = string
  default     = "ip=dhcp"
}

variable "ipconfig1" {
  description = "Cloud-init IP config for NIC 1 (same format as ipconfig0)"
  type        = string
  default     = null
}

// ipconfig2 removed (module supports ipconfig0/ipconfig1). Add back if needed later


# Custom Sizes
variable "instance_size" {
  description = "Preset size key (xsmall, small, medium, large, xlarge). Empty to use custom values"
  type        = string
  default     = ""
}

variable "cpu" {
  description = "Explicit CPU configuration (overrides cores/sockets/vcpus variables)"
  type = object({
    cores   = number
    sockets = number
    vcores  = number
  })
  default = null
}

variable "instance_sizes" {
  description = "Map of size presets defining memory, cores, sockets, vcores, and disk size"
  type = map(object({
    memory  = number
    cores   = number
    sockets = number
    vcores  = number
    size    = string
  }))
  default = {
    xsmall = { memory = 2048, cores = 1, sockets = 1, vcores = 1, size = "10G" }
    small  = { memory = 4096, cores = 2, sockets = 1, vcores = 2, size = "12G" }
    medium = { memory = 8192, cores = 4, sockets = 1, vcores = 4, size = "20G" }
    large  = { memory = 16384, cores = 8, sockets = 1, vcores = 8, size = "40G" }
    xlarge = { memory = 32768, cores = 10, sockets = 1, vcores = 10, size = "60G" }
  }
}
