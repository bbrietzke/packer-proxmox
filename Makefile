proxmox_storage_pool = 

.PHONY: ubuntu2404 all

all: ubuntu2404

ubuntu2404:
	packer init ubuntu2404/packer.pkr.hcl
	packer build -var-file variables.pkvars.hcl ubuntu2404/packer.pkr.hcl

alma10:
	packer init almalinux10/packer.pkr.hcl
	PACKER_LOG=1 packer build -var-file alma10.pkvars.hcl almalinux10/packer.pkr.hcl