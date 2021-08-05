# Docker Networking with EC2 Prefix Assignment 

## What is this repository for?

This is an example Terraform project which deploys a docker host on EC2. The instance includes an ENI
to which a /28 and /80 IP prefixes have been assigned using the new AWS VPC EC2 IP prefix assignment.

### Dependencies

This project assumes that you are already familiar with AWS and Terraform.

There are several dependencies that are needed before the Terraform project can be run. Make sure that you have:

- The [Terraform](https://www.terraform.io) 0.14 binary installed and available on the PATH.
- AWS credentials configured via environment variables or credentials file


### Configure the project properties

Edit the vars.tf to include your SSH key and source IPv4 address.

```
variable "management_prefix" {
  default = "x.x.x.x/32"
}
```

## Deployment

### Generate an SSH public/private key pair named mykey

`ssh-keygen -f mykey`

### Initialize the modules

`terraform init`

### Plan the deployment

`terraform plan -var-file="user.tfvars"`

### Apply the deployment

`terraform apply`

In the output of terraform apply, you will see the FQDN of the docker host.

### Destroy the deployment

`terraform destroy`

## Additional Information

This repo is intended to accompany the blog article at https://konekti.us/post/container-networking-with-ec2-ip-prefix-assignments.

For any questions, please contact me at jeffl@konekti.us.