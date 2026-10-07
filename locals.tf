locals {
  ssh_sg_description        = "Security Group for Open Web UI SSH"
  http_sg_description       = "Security Group for Open Web UI HTTP"
  vpc_description           = "VPC for Open Web UI"
  subnet_description        = "Subnet for Open Web UI"
  igw_description           = "Internet Gateway for Open Web UI"
  route_table_description   = "Route Table for Open Web UI"
  ssh_ingress_description   = "SSH from anywhere"
  http_ingress_description  = "HTTP from anywhere"
  egress_description        = "All outbound traffic"
  key_pair_description      = "Key Pair for Open Web UI"
  spot_instance_description = "Spot Instance for Open Web UI"
}
