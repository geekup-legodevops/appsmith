NAME = appsmith
VERSION = 1.0
VPC_ID ?= vpc-41b8bd29
SUBNET_ID ?= subnet-52a1833a
DIGITALOCEAN_TOKEN ?= dop_v1_39b06ccf44383254e49202c1a074c6fdac476ee34714734c1c69bea5636000f3
.DEFAULT_GOAL := all

.PHONY: all

all:
	packer build -var 'vpc_id=$(VPC_ID)' -var 'subnet_id=$(SUBNET_ID)' -var 'token=$(DIGITALOCEAN_TOKEN)' template.json.pkr.hcl
