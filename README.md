<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 3.0.1-rc8 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 3.0.1-rc8 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_vm_qemu.pvevm](https://registry.terraform.io/providers/Telmate/proxmox/3.0.1-rc8/docs/resources/vm_qemu) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent"></a> [agent](#input\_agent) | Qemu Guest Agent Enabled or not enabled=1 | `number` | `1` | no |
| <a name="input_bridge"></a> [bridge](#input\_bridge) | Map of tags to add to the VM. Stored as JSON in the Notes field in Proxmox. | `string` | `"vmbr0"` | no |
| <a name="input_cipassword"></a> [cipassword](#input\_cipassword) | Override the default cloud-init user's password | `string` | n/a | yes |
| <a name="input_ciuser"></a> [ciuser](#input\_ciuser) | Override the default cloud-init user for provisioning | `string` | n/a | yes |
| <a name="input_clone"></a> [clone](#input\_clone) | The base VM from which to clone to create the new VM | `string` | n/a | yes |
| <a name="input_connection"></a> [connection](#input\_connection) | Provisioner connection settings | `map(string)` | <pre>{<br/>  "agent": true,<br/>  "type": "ssh"<br/>}</pre> | no |
| <a name="input_cores"></a> [cores](#input\_cores) | The number of CPU cores per CPU socket to allocate to the VM | `number` | `null` | no |
| <a name="input_disks"></a> [disks](#input\_disks) | VM disk config | `list(map(string))` | <pre>[<br/>  {}<br/>]</pre> | no |
| <a name="input_gateway"></a> [gateway](#input\_gateway) | Gateway IP Address | `string` | `""` | no |
| <a name="input_id"></a> [id](#input\_id) | New required field proxmox | `number` | `0` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Instance Count | `number` | `1` | no |
| <a name="input_instance_size"></a> [instance\_size](#input\_instance\_size) | The size of the instance (small, medium, large). If empty, custom values must be provided. | `string` | `""` | no |
| <a name="input_instance_sizes"></a> [instance\_sizes](#input\_instance\_sizes) | Map of instance sizes with predefined settings | <pre>map(object({<br/>    memory  = number<br/>    cores   = number<br/>    sockets = number<br/>    vcpus   = number<br/>    size    = string<br/>  }))</pre> | <pre>{<br/>  "large": {<br/>    "cores": 8,<br/>    "memory": 16384,<br/>    "size": "40G",<br/>    "sockets": 1,<br/>    "vcpus": 8<br/>  },<br/>  "medium": {<br/>    "cores": 4,<br/>    "memory": 8192,<br/>    "size": "20G",<br/>    "sockets": 1,<br/>    "vcpus": 4<br/>  },<br/>  "small": {<br/>    "cores": 2,<br/>    "memory": 4096,<br/>    "size": "12G",<br/>    "sockets": 1,<br/>    "vcpus": 2<br/>  },<br/>  "xlarge": {<br/>    "cores": 10,<br/>    "memory": 32768,<br/>    "size": "60G",<br/>    "sockets": 1,<br/>    "vcpus": 10<br/>  },<br/>  "xsmall": {<br/>    "cores": 1,<br/>    "memory": 2048,<br/>    "size": "10G",<br/>    "sockets": 1,<br/>    "vcpus": 1<br/>  }<br/>}</pre> | no |
| <a name="input_ip_addresses"></a> [ip\_addresses](#input\_ip\_addresses) | List of IP addresses with cidr notation | `list(string)` | `[]` | no |
| <a name="input_ipconfig0"></a> [ipconfig0](#input\_ipconfig0) | The first IP address to assign to the guest. Format: [gw=<GatewayIPv4>] [,gw6=<GatewayIPv6>] [,ip=<IPv4Format/CIDR>] [,ip6=<IPv6Format/CIDR>] | `string` | `"ip=dhcp"` | no |
| <a name="input_ipconfig1"></a> [ipconfig1](#input\_ipconfig1) | The second IP address to assign to the guest. Same format as ipconfig0 | `string` | `null` | no |
| <a name="input_ipconfig2"></a> [ipconfig2](#input\_ipconfig2) | The third IP address to assign to the guest. Same format as ipconfig0 | `string` | `null` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount of memory to allocate to the VM in Megabytes | `number` | `null` | no |
| <a name="input_model"></a> [model](#input\_model) | Network Model | `string` | `"virtio"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the VM within Proxmox | `string` | n/a | yes |
| <a name="input_nameserver"></a> [nameserver](#input\_nameserver) | Sets default DNS server for guest | `string` | `null` | no |
| <a name="input_networks"></a> [networks](#input\_networks) | VM network adapter config | `list(map(string))` | <pre>[<br/>  {}<br/>]</pre> | no |
| <a name="input_notes"></a> [notes](#input\_notes) | VM notes field that maps to desc | `string` | `"Managed by Terraform."` | no |
| <a name="input_ostype"></a> [ostype](#input\_ostype) | The OS Type | `string` | `"cloud-init"` | no |
| <a name="input_pool"></a> [pool](#input\_pool) | The destination resource pool for the new VM | `string` | `null` | no |
| <a name="input_proxmox_api_token_id"></a> [proxmox\_api\_token\_id](#input\_proxmox\_api\_token\_id) | API Token | `string` | n/a | yes |
| <a name="input_proxmox_api_token_secret"></a> [proxmox\_api\_token\_secret](#input\_proxmox\_api\_token\_secret) | API Secret | `string` | n/a | yes |
| <a name="input_proxmox_api_url"></a> [proxmox\_api\_url](#input\_proxmox\_api\_url) | Full Proxmox API URL | `string` | n/a | yes |
| <a name="input_proxmox_tls_insecure"></a> [proxmox\_tls\_insecure](#input\_proxmox\_tls\_insecure) | Allow Insecure TLS | `bool` | `true` | no |
| <a name="input_scsihw"></a> [scsihw](#input\_scsihw) | scsi hardware type | `string` | `"virtio-scsi-pci"` | no |
| <a name="input_searchdomain"></a> [searchdomain](#input\_searchdomain) | Sets default DNS search domain suffix | `string` | `null` | no |
| <a name="input_serial0"></a> [serial0](#input\_serial0) | serial device in order for console device to work | `number` | `0` | no |
| <a name="input_size"></a> [size](#input\_size) | Disk Size | `string` | `null` | no |
| <a name="input_sockets"></a> [sockets](#input\_sockets) | The number of CPU sockets to allocate to the VM | `number` | `null` | no |
| <a name="input_sshkeys"></a> [sshkeys](#input\_sshkeys) | Newline delimited list of SSH public keys to add to authorized keys file for the cloud-init user | `string` | n/a | yes |
| <a name="input_storage"></a> [storage](#input\_storage) | Disk Storage Location | `string` | n/a | yes |
| <a name="input_tag"></a> [tag](#input\_tag) | Vlan ID | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | tags comma seperated | `string` | `""` | no |
| <a name="input_target_node"></a> [target\_node](#input\_target\_node) | The name of the Proxmox Node on which to place the VM | `string` | `null` | no |
| <a name="input_target_nodes"></a> [target\_nodes](#input\_target\_nodes) | The name of the Proxmox Node on which to place the VM | `list(string)` | `null` | no |
| <a name="input_vcpus"></a> [vcpus](#input\_vcpus) | The number of vCPU  to allocate to the VM | `number` | `null` | no |
| <a name="input_vmid"></a> [vmid](#input\_vmid) | The vm id of the VM within Proxmox. Default is next available | `number` | `0` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | VM IDS |
| <a name="output_vm_ip"></a> [vm\_ip](#output\_vm\_ip) | VM IP Addresses |
| <a name="output_vm_memory"></a> [vm\_memory](#output\_vm\_memory) | VM Memory |
| <a name="output_vm_name"></a> [vm\_name](#output\_vm\_name) | VM NAMES |
| <a name="output_vm_nameserver"></a> [vm\_nameserver](#output\_vm\_nameserver) | VM Nameservers |
| <a name="output_vm_vcpus"></a> [vm\_vcpus](#output\_vm\_vcpus) | VM VCPUS |
<!-- END_TF_DOCS -->