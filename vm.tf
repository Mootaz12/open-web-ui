data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]
  filter {
    name   = "name"
    values = ["debian-11-amd64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "open_web_ui" {
  cidr_block            = "10.0.0.0/16"
  enable_dns_hostnames  = true
  enable_dns_support    = true
  tags = {
    Name = "open-web-ui"
  }
}
resource "aws_subnet" "subnet" {
  cidr_block        = cidrsubnet(aws_vpc.open_web_ui.cidr_block,3,1)
  vpc_id            = aws_vpc.open_web_ui.id
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet"
  }
}
resource "aws_internet_gateway" "igw_open_web_ui" {
  vpc_id = aws_vpc.open_web_ui.id
}

resource "aws_route_table" "rt_open_web_ui" {
  vpc_id = aws_vpc.open_web_ui.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_open_web_ui.id
  }
}

resource "aws_route_table_association" "rt_association_open_web_ui" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt_open_web_ui.id
}

resource "aws_security_group" "sg_open_web_ui_ssh" {
  vpc_id = aws_vpc.open_web_ui.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_key_pair" "open_web_ui" {
  key_name   = "open-web-ui"
  public_key = file("~/.ssh/patientping-key.pub")
}

resource "aws_spot_instance_request" "cheap_worker" {
  ami            = data.aws_ami.debian.id
  instance_type = "t3.micro"
  associate_public_ip_address = true
  key_name       = aws_key_pair.open_web_ui.key_name
  vpc_security_group_ids = [aws_security_group.sg_open_web_ui_ssh.id]
  subnet_id      = aws_subnet.subnet.id
  wait_for_fulfillment = true
  tags = {
    Name = "cheap-worker"
  }
}
