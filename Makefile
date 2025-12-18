proxmox_storage_pool = 

.PHONY: ubuntu2404 all alma10 rocky10 centos10

all: ubuntu2404 alma10 rocky10 centos10

ubuntu2404:
	packer init ubuntu2404/packer.pkr.hcl
	packer build -var-file variables.pkvars.hcl ubuntu2404/packer.pkr.hcl

alma10:
	packer init almalinux10/packer.pkr.hcl
	PACKER_LOG=1 packer build -var-file alma10.pkvars.hcl almalinux10/packer.pkr.hcl

rocky10:
	packer init rocky10/
	packer build -var-file rocky10.pkvars.hcl rocky10/

centos10:
	packer init centos10/
	PACKER_LOG=1 packer build -debug -var-file centos10.pkvars.hcl centos10/