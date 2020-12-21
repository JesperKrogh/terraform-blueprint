# terraform-blueprint

This repository contains blueprint for running Ceph on AWS
This can be used for spinning up a test-cluster to take a good 
run of http://ceph.io. 

One could ask "why would you ever want to do this"? 

Purpose could be:

* Get hands-on experience managing a Ceph cluster - Grow, Shrink, updgrade, etc. 
* Performance test Ceph (compare to local storage allready in place) 
* Currently supports RDB devices (Buckets and CephFS is coming when the ceph-ansible changes are in place)

Current version is compatible with ceph-ansible/stable-5.0 branch and runs on Ubuntu 18.04 
(Still work in progress) 

More blueprints may be added over time. 

What you'll need (for now) - changes in terraform.tfvars file: 

1. Generate ssh key for the hosts and change it
2. Configure amount of instances (mons, osds) - MDSs are coming
3. Modify instance types if defauls are unfit. 
4. Setup aws cli (using access tokens)
5. $ terraform init && terraform apply (type yes) 


Currently it will setup: 

* A seperate VPC (10.0.0.0/16) 
* 1 subnet 10.0.1.0/24 (for a single management host) with an elastic IP assigned. 
* 1 subnet 10.0.0.0/24 (for all the Ceph nodes) with internet through a NAT gateway. 




