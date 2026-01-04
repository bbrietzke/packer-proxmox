proxmox_api_url             = "https://192.168.1.7:8006/api2/json"
proxmox_api_token_id        = "root@pam!packer"
proxmox_api_token_secret    = "8f4b085b-a81e-4231-8007-11436bed84b0"
proxmox_node                = "PVE00"

root_password               = "password"
timezone                    = "US/Chicago"

ssh_public_key              = "SSH_KEY"

vm_cores                    = "2"
vm_memory                   = "8192"
vm_disk_size                = "32G"
vm_storage_pool             = "local-lvm"
vm_disk_format              = "raw"
cpu_type                    = "x86-64-v3"

iso_storage_pool            = "local:iso"

ubuntu_iso                  = "local:iso/ubuntu-24.04.3-live-server-amd64.iso"
rocky_iso                   = "local:iso/Rocky-10.1-x86_64-minimal.iso"
centos_iso                  = "local:iso/CentOS-Stream-10-latest-x86_64-dvd1.iso"
alma_iso                    = "local:iso/AlmaLinux-10.1-x86_64-minimal.iso"