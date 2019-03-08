variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
}

variable "key_name" {
  description = "Desired name of AWS key pair"
}
variable "chkp_instance_size" {
  description = "Check Point Instance Size"
}
variable "aws_vpc_cidr" {
}
variable "chkp_mgmt_private_ip" {
}
variable "aws_vpc_name" {
}
variable "aws_external1_subnet_cidr" {
}
variable "aws_external2_subnet_cidr" {
}
variable "my_user_data" {
}
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}
variable "primary_az" {
  description = "primary AZ"
  default     = "us-east-1a"
}
# Check Point R80 BYOL
data "aws_ami" "chkp_ami" {
  most_recent      = true
  filter {
    name   = "name"
    values = ["Check Point CloudGuard IaaS BYOL R80.20-*"]
  }
  owners = ["679593333241"]
}
