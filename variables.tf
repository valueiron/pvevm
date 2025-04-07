#####################################################
# PROXMOX API
#####################################################
variable "proxmox_api_url" {
  description = "Full Proxmox API URL"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "API Token"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "API Secret"
  type        = string
}

variable "proxmox_tls_insecure" {
  description = "Allow Insecure TLS"
  type        = bool
  default     = true
}

#####################################################
# VM QEMU Resource
#####################################################
variable "name" {
  description = "The name of the VM within Proxmox"
  type        = string
}

variable "vmid" {
  description = "The vm id of the VM within Proxmox. Default is next available"
  type        = number
  default     = 0

  validation {
    condition     = var.vmid == 0 || (var.vmid >= 100 && var.vmid <= 999999999)
    error_message = "vmid must be 0 (for auto) or between 100 and 999999999."
  }
}

variable "notes" {
  description = "VM notes field that maps to desc"
  type        = string
  default     = "Managed by Terraform."
}

variable "target_node" {
  description = "The name of the Proxmox Node on which to place the VM"
  type        = string
  default     = null
}

variable "target_nodes" {
  description = "The name of the Proxmox Node on which to place the VM"
  type        = list(string)
  default     = null
}

variable "clone" {
  description = "The base VM from which to clone to create the new VM"
  type        = string
}

variable "memory" {
  description = "The amount of memory to allocate to the VM in Megabytes"
  type        = number
  default     = null
}

variable "scsihw" {
  description = "scsi hardware type"
  type        = string
  default     = "virtio-scsi-pci"
}

variable "cores" {
  description = "The number of CPU cores per CPU socket to allocate to the VM"
  type        = number
  default     = null
}

variable "sockets" {
  description = "The number of CPU sockets to allocate to the VM"
  type        = number
  default     = null
}

variable "vcpus" {
  description = "The number of vCPU  to allocate to the VM"
  type        = number
  default     = null
}

variable "agent" {
  description = "Qemu Guest Agent Enabled or not enabled=1"
  type        = number
  default     = 1
}

variable "serial0" {
  description = "serial device in order for console device to work"
  type        = number
  default     = 0
}

variable "tags" {
  description = "tags comma seperated"
  type        = string
  default     = ""
}

############################## NETWORK
variable "bridge" {
  description = "Map of tags to add to the VM. Stored as JSON in the Notes field in Proxmox."
  type        = string
  default     = "vmbr0"
}

variable "id" {
  description = "New required field proxmox"
  type        = number
  default     = 0
}

variable "model" {
  description = "Network Model"
  type        = string
  default     = "virtio"
}

variable "tag" {
  description = "Vlan ID"
  type        = number
  default     = null
}

variable "ip_addresses" {
  description = "List of IP addresses with cidr notation"
  type        = list(string)
  default     = []
}

variable "gateway" {
  description = "Gateway IP Address"
  type        = string
  default     = ""
}

######################### STORAGE
variable "storage" {
  description = "Disk Storage Location"
  type        = string
}

variable "size" {
  description = "Disk Size"
  type        = string
  default     = null
}


################################# Not being used just yet but will be used in the new module
variable "networks" {
  description = "VM network adapter config"
  type        = list(map(string))
  default     = [{}]
}

variable "connection" {
  description = "Provisioner connection settings"
  type        = map(string)
  sensitive   = true
  default = {
    type  = "ssh"
    agent = true
  }
}

variable "pool" {
  description = "The destination resource pool for the new VM"
  type        = string
  default     = null
}


variable "disks" {
  description = "VM disk config"
  type        = list(map(string))
  default     = [{}]
}

variable "instance_count" {
  description = "Instance Count"
  type        = number
  default     = 1
}

#####################################################
# Cloud-Init
#####################################################
variable "ostype" {
  description = "The OS Type"
  type        = string
  default     = "cloud-init"
}

variable "ciuser" {
  description = "Override the default cloud-init user for provisioning"
  type        = string
}

variable "cipassword" {
  description = "Override the default cloud-init user's password"
  type        = string
  sensitive   = true
}

variable "searchdomain" {
  description = "Sets default DNS search domain suffix"
  type        = string
  default     = null
}

variable "nameserver" {
  description = "Sets default DNS server for guest"
  type        = string
  default     = null
}

variable "sshkeys" {
  description = "Newline delimited list of SSH public keys to add to authorized keys file for the cloud-init user"
  type        = string
}

variable "ipconfig0" {
  description = "The first IP address to assign to the guest. Format: [gw=<GatewayIPv4>] [,gw6=<GatewayIPv6>] [,ip=<IPv4Format/CIDR>] [,ip6=<IPv6Format/CIDR>]"
  type        = string
  default     = "ip=dhcp"
}

variable "ipconfig1" {
  description = "The second IP address to assign to the guest. Same format as ipconfig0"
  type        = string
  default     = null
}

variable "ipconfig2" {
  description = "The third IP address to assign to the guest. Same format as ipconfig0"
  type        = string
  default     = null
}


# Custom Sizes
variable "instance_size" {
  description = "The size of the instance (small, medium, large). If empty, custom values must be provided."
  type        = string
  default     = ""
}

variable "instance_sizes" {
  description = "Map of instance sizes with predefined settings"
  type = map(object({
    memory  = number
    cores   = number
    sockets = number
    vcpus   = number
    size    = string
  }))
  default = {
    xsmall = { memory = 2048, cores = 1, sockets = 1, vcpus = 1, size = "10G" }
    small  = { memory = 4096, cores = 2, sockets = 1, vcpus = 2, size = "12G" }
    medium = { memory = 8192, cores = 4, sockets = 1, vcpus = 4, size = "20G" }
    large  = { memory = 16384, cores = 8, sockets = 1, vcpus = 8, size = "40G" }
    xlarge = { memory = 32768, cores = 10, sockets = 1, vcpus = 10, size = "60G" }
  }
}
