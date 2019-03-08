# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "${var.aws_vpc_cidr}"
  tags {
    Name = "${var.aws_vpc_name}"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Define an external subnet for the security layer facing internet in the primary availability zone
resource "aws_subnet" "external1" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.aws_external1_subnet_cidr}"
  map_public_ip_on_launch = true
  availability_zone       = "${var.primary_az}"
  tags {
    Name = "Terraform_external1"
  }
}

# Our default security group to access
resource "aws_security_group" "permissive" {
  name        = "terraform_permissive_sg"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.default.id}"


  # access from the internet
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Check Point Management Server
resource "aws_instance" "CHKP_Management_Server" {
  tags {
 	Name = "CPX2019_Management_Server"
       }
  ami           = "${data.aws_ami.chkp_ami.id}"
  instance_type = "${var.chkp_instance_size}"
  key_name      = "${var.key_name}"
  user_data     = "${var.my_user_data}"
  security_groups = ["${aws_security_group.permissive.id}"]
  subnet_id     = "${aws_subnet.external1.id}"
  private_ip    = "${var.chkp_mgmt_private_ip}"
  iam_instance_profile = "${aws_iam_instance_profile.Check_Point_Instance_profile.id}"
}

#Create EIP for the Check Point Management Server
resource "aws_eip" "CHKP_Management_EIP" {
  instance = "${aws_instance.CHKP_Management_Server.id}"
  vpc      = true
}

resource "aws_iam_role" "CHKP_role" {
  name = "Check_Point_Management_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
#Create Check Point Instance Profile
resource "aws_iam_instance_profile" "Check_Point_Instance_profile" {
  name = "Check_Point_instance_profile"
  role = "${aws_iam_role.CHKP_role.name}"
}

#Create the IAM role for the Check Point Management Server
resource "aws_iam_role_policy" "R80Mgmtpolicy" {
  name        = "Check_Point_Mgmt_Policy"
  role        = "${aws_iam_role.CHKP_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSubnets",
        "ec2:DescribeInstances",
        "ec2:DescribeVpcs",
        "ec2:DescribeVpnGateways",
        "ec2:DescribeVpnConnections",
        "ec2:DescribeSecurityGroups",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeTargetHealth",
        "autoscaling:DescribeAutoScalingGroups"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
