
.PHONY: ubuntu2404 all alma10 rocky10 centos10 kube

all: ubuntu2404 alma10 rocky10 centos10 kube

kube:
	packer init ubuntu_kube/packer.pkr.hcl
	packer build -var-file variables.pkvars.hcl -var "machine_id=999999995" ubuntu_kube/

ubuntu2404:
	packer init ubuntu2404/packer.pkr.hcl
	packer build -var-file variables.pkvars.hcl -var "machine_id=999999999" ubuntu2404/

alma10:
	packer init almalinux10/packer.pkr.hcl
	packer build -var-file variables.pkvars.hcl -var "machine_id=999999998"  almalinux10/

rocky10:
	packer init rocky10/
	packer build -var-file variables.pkvars.hcl -var "machine_id=999999997"  rocky10/

centos10:
	packer init centos10/
	packer build -var-file variables.pkvars.hcl -var "machine_id=999999996"  centos10/