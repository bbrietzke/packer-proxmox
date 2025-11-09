proxmox_api_url             = "https://pve.faultycloud.io/api2/json"
proxmox_api_token_id        = "root@pam!packer2"
proxmox_api_token_secret    = "20de1f11-4197-4d39-bef5-6952411857da"
proxmox_node                = "pve0"

root_password               = "password"
timezone                    = "US/Chicago"

ssh_public_key              = "SSH_KEY"

vm_cores                    = "2"
vm_memory                   = "8192"
vm_disk_size                = "32G"
vm_storage_pool             = "local-lvm"
vm_disk_format              = "raw"

iso_storage_pool            = "local:iso"

ubuntu2404_iso              = "local:iso/ubuntu-24.04.3-live-server-amd64.iso"