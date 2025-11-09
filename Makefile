proxmox_storage_pool = 

.PHONY: ubuntu2404 all

all: ubuntu2204

ubuntu2404:
	packer init ubuntu2404/packer.pkr.hcl
	packer build -var-file variables.pkvars.hcl ubuntu2404/packer.pkr.hcl