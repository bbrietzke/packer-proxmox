
.PHONY: ubuntu2404 all alma10 rocky10 centos10 kube ubuntu2604

all: ubuntu2604 ubuntu2404 alma10 rocky10 centos10 kube openclaw

ubuntu2404:
	packer init ubuntu2404/packer.pkr.hcl
	packer build -var-file variables.pkvars.hcl -var "machine_id=999999999" ubuntu2404/

ubuntu2604:
	packer init ubuntu2604/packer.pkr.hcl
	packer build -var-file variables.pkvars.hcl -var "machine_id=999999998" ubuntu2604/

alma10:
	packer init almalinux10/packer.pkr.hcl
	packer build -var-file variables.pkvars.hcl -var "machine_id=999999997"  almalinux10/

rocky10:
	packer init rocky10/
	packer build -var-file variables.pkvars.hcl -var "machine_id=999999996"  rocky10/

centos10:
	packer init centos10/
	packer build -var-file variables.pkvars.hcl -var "machine_id=999999995"  centos10/

kube:
	packer init ubuntu_kube/packer.pkr.hcl
	packer build -var-file variables.pkvars.hcl -var "machine_id=999999994" ubuntu_kube/

openclaw:
	packer init ubuntu_openclaw/packer.pkr.hcl
	packer build -var-file variables.pkvars.hcl -var "machine_id=999999993" ubuntu_openclaw/
