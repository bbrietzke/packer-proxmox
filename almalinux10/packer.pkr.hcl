packer {
  required_plugins {
    name = {
      version = "~> 1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Variable Definitions
variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

variable "proxmox_node" {
    type = string
}

variable "root_password" {
    type = string
    sensitive = true
    description = "Unencrypted root password for the VM"
}

variable "timezone" {
    type = string
    description = "Timezone for the VM"
}

variable "ssh_public_key" {
    type = string
    description = "SSH public key to add to root account"
}

variable "vm_cores" {
    type = string
    description = "Number of CPU cores for the VM"
}

variable "vm_memory" {
    type = string
    description = "Amount of memory for the VM in MB"
}

variable "vm_disk_size" {
    type = string
    description = "Disk size for the VM"
}

variable "vm_storage_pool" {
    type = string
    description = "Storage pool for VM disk"
}

variable "vm_disk_format" {
    type = string
    description = "Disk format (raw, qcow2, etc.)"
}

variable "iso_storage_pool" {
    type = string
    description = "Storage pool for ISO files"
}

variable "installation_iso" {
    type = string
    description = "Path to the ISO file to install"
}

variable "machine_id" {
    type = string
    description = "The VM_ID to create"
}

source "proxmox-iso" "alma10" {
 
    proxmox_url                 = "${var.proxmox_api_url}"
    username                    = "${var.proxmox_api_token_id}"
    token                       = "${var.proxmox_api_token_secret}"
    insecure_skip_tls_verify    = true

    node                        = "${var.proxmox_node}"
    vm_name                     = "alma10-${formatdate("YYYYMMDD", timestamp())}"
    vm_id                       = "${var.machine_id}" 
    template_description        = "Alma Linux 10"

    # Replace deprecated ISO parameters with boot_iso block
    boot_iso {
        iso_file                = "${var.installation_iso}"
        iso_storage_pool        = "${var.iso_storage_pool}"
        unmount                 = true
        iso_checksum            = "none"
    }
    
    template_name               = "alma10-${formatdate("YYYYMMDD", timestamp())}"

    qemu_agent                  = true

    scsi_controller             = "virtio-scsi-single"

    disks {
        disk_size               = "${var.vm_disk_size}"
        format                  = "${var.vm_disk_format}"
        storage_pool            = "${var.vm_storage_pool}"
        type                    = "scsi"
    }

    cores                       = "${var.vm_cores}"
    memory                      = "${var.vm_memory}" 
    cpu_type                    = "host"
    network_adapters {
        model                   = "virtio"
        bridge                  = "vmbr0"
        firewall                = "false"
    } 

    cloud_init                  = true
    cloud_init_storage_pool     = "${var.vm_storage_pool}"
  
    
    boot_command = [
        "e",
        "<down><down>",
        "<leftCtrlOn>e<leftCtrlOff>",
        "<spacebar>",
        "biosdevname=0",
        "<spacebar>",
        "net.ifnames=0",
        "<spacebar>",
        "inst.text",
        "<spacebar>",
        "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/starter.ks",
        "<leftCtrlOn>x<leftCtrlOff>",
    ]
    boot                    = "c"
    boot_wait               = "5s"

    # Use templatefile function to process the user-data template with variables
    http_content = {
        "/starter.ks" = file("http/starter.ks")
        "/meta-data" = file("http/meta-data")
        "/user-data" = templatefile("http/user-data.pkrtpl.hcl", {
            root_password = var.root_password
            ssh_public_key = var.ssh_public_key
            timezone = var.timezone
        })
    }

    ssh_username            = "root"
    ssh_password            = "${var.root_password}"
    ssh_timeout             = "20m"
}

build {

    name = "almalinux-10"
    sources = ["proxmox-iso.alma10"]

    provisioner "shell" {
        inline = [
            # "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 10; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo cloud-init clean -c all --machine-id",
            "sudo rm -rf /var/lib/cloud",
        ]
    }    
}