packer {
  required_plugins {
    name = {
      version = "~> 1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "ubuntu-server-noble-numbat" {
 
    proxmox_url                 = "${var.proxmox_api_url}"
    username                    = "${var.proxmox_api_token_id}"
    token                       = "${var.proxmox_api_token_secret}"
    insecure_skip_tls_verify    = true

    node                        = "${var.proxmox_node}"
    vm_name                     = "ubuntu-${formatdate("YYYYMMDD", timestamp())}"
    vm_id                       = "${var.machine_id}" 
    template_description        = "Resolute Raccoon"

    boot_iso {
        iso_file                = "${var.ubuntu_iso}"
        iso_storage_pool        = "${var.iso_storage_pool}"
        unmount                 = true
        iso_checksum            = "none"
    }
    
    template_name               = "ubuntu26.04-${formatdate("YYYYMMDD", timestamp())}"

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
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]
    boot                    = "c"
    boot_wait               = "5s"

    # Use templatefile function to process the user-data template with variables
    http_content = {
        "/meta-data" = file("http/meta-data")
        "/user-data" = templatefile("http/user-data.pkrtpl.hcl", {
            root_password = var.root_password
            ssh_public_key = var.ssh_public_key
            timezone = var.timezone
        })
    }

    ssh_username            = "ubuntu"
    ssh_password            = "${var.root_password}"
    ssh_timeout             = "20m"
}

build {

    name = "ubuntu-server-noble-numbat"
    sources = ["proxmox-iso.ubuntu-server-noble-numbat"]

    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 10; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo rm -f /etc/netplan/00-installer-config.yaml",
            "sudo sync"
        ]
    }    

    provisioner "file" {
        source = "ubuntu2404/files/99-netcfg.yaml"
        destination = "/tmp/99-netcfg.cfg"
    }
    
    provisioner "file" {
        source = "ubuntu2404/files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    provisioner "shell" {
        inline = [ 
          "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg",
          "sudo cp /tmp/99-netcfg.cfg /etc/netplan/99-netcfg.yaml",
          "sudo chmod 600 /etc/netplan/99-netcfg.yaml"
        ]
    }
}
