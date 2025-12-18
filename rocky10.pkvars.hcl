proxmox_api_url             = "https://192.168.3.7:8006/api2/json"
proxmox_api_token_id        = "root@pam!packer"
proxmox_api_token_secret    = "2ed0814b-ca0f-4ad8-a58d-7996f3abd74d"
proxmox_node                = "pve0"

root_password               = "rocky"
timezone                    = "US/Chicago"

ssh_public_key              = "SSH_KEY"

vm_cores                    = "2"
vm_memory                   = "8192"
vm_disk_size                = "16G"
vm_storage_pool             = "local-lvm"
vm_disk_format              = "raw"
machine_id                  = "999999997"

iso_storage_pool            = "local:iso"

installation_iso            = "local:iso/Rocky-10.1-x86_64-minimal.iso"