packer {
  required_plugins {
    name = {
      version = "~> 1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
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

    boot_iso {
        iso_file                = "${var.alma_iso}"
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
    cpu_type                    = "${var.cpu_type}"

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