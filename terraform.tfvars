# Adjust vars for the AWS settings and region
# These VPCs, subnets, and gateways will be created as part of the demo
public_key_path = "~/.ssh/id_rsa.pub"
aws_region = "us-east-2"
key_name = "awssshkey"
aws_vpc_cidr = "10.0.0.0/16"
aws_vpc_name = "CPX2019_Mmgt_VPC"
chkp_mgmt_private_ip = "10.0.1.10"
aws_external1_subnet_cidr = "10.0.1.0/24"
aws_external2_subnet_cidr = "10.0.2.0/24"
chkp_instance_size = "m5.xlarge"
my_user_data = <<-EOF
                #!/bin/bash
                clish -c 'set user admin shell /bin/bash' -s
                config_system -s 'install_security_gw=false&install_ppak=false&gateway_cluster_member=false&install_security_managment=true&install_mgmt_primary=true&install_mgmt_secondary=false&download_info=true&hostname=R80dot10Mgmt&mgmt_gui_clients_radio=any&mgmt_admin_name=adminaws&mgmt_admin_passwd=Vpn12345';/opt/CPvsec-R80/bin/vsec on;shutdown -r now;
                EOF
