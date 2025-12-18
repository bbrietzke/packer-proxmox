

source "proxmox-iso" "centos10" {
 
    proxmox_url                 = "${var.proxmox_api_url}"
    username                    = "${var.proxmox_api_token_id}"
    token                       = "${var.proxmox_api_token_secret}"
    insecure_skip_tls_verify    = true

    node                        = "${var.proxmox_node}"
    vm_name                     = "centos10-${formatdate("YYYYMMDD", timestamp())}"
    vm_id                       = "${var.machine_id}" 
    template_description        = "Centos Stream 10"

    # Replace deprecated ISO parameters with boot_iso block
    boot_iso {
        iso_file                = "${var.installation_iso}"
        iso_storage_pool        = "${var.iso_storage_pool}"
        unmount                 = true
        iso_checksum            = "none"
    }
    
    template_name               = "centos10-${formatdate("YYYYMMDD", timestamp())}"

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
        "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kickstarter.cfg",
        "<leftCtrlOn>x<leftCtrlOff>",
    ]
    boot                    = "c"
    boot_wait               = "5s"

    # Use templatefile function to process the user-data template with variables
    http_content = {
        "/kickstarter.cfg" = templatefile("http/kickstarter.cfg.pkrtpl.hcl", {
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

    name = "centos-10"
    sources = ["proxmox-iso.centos10"]

    provisioner "shell" {
        inline = [
            # "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 10; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo cloud-init clean -c all --machine-id",
            "sudo rm -rf /var/lib/cloud",
        ]
    }    
}