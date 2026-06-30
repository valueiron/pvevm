variable "cipassword" {
  description = "Cloud-init user password"
  type        = string
  sensitive   = true
}

variable "sshkeys" {
  description = "Newline-delimited SSH public keys"
  type        = string
  default     = null
}
