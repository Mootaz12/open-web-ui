data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]
  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "open_web_ui" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "open-web-ui"
    description = local.vpc_description
  }
}
resource "aws_subnet" "open_web_ui" {
  cidr_block        = cidrsubnet(aws_vpc.open_web_ui.cidr_block, 3, 1)
  vpc_id            = aws_vpc.open_web_ui.id
  availability_zone = "us-east-1a"
  tags = {
    Name        = "subnet"
    description = local.subnet_description
  }
}
resource "aws_internet_gateway" "open_web_ui" {
  vpc_id = aws_vpc.open_web_ui.id
  tags = {
    Name        = "open-web-ui"
    description = local.igw_description
  }
}

resource "aws_route_table" "open_web_ui" {
  vpc_id = aws_vpc.open_web_ui.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.open_web_ui.id
  }
  tags = {
    Name        = "open-web-ui"
    description = local.route_table_description
  }
}

resource "aws_route_table_association" "open_web_ui" {
  subnet_id      = aws_subnet.open_web_ui.id
  route_table_id = aws_route_table.open_web_ui.id
}

resource "aws_security_group" "open_web_ui_ssh" {
  name        = "open-web-ui-ssh"
  description = local.ssh_sg_description
  vpc_id      = aws_vpc.open_web_ui.id
  ingress {
    description = local.ssh_ingress_description
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  egress {
    description = local.egress_description
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  tags = {
    Name        = "open-web-ui-ssh"
    description = local.ssh_sg_description
  }
}

resource "aws_security_group" "open_web_ui_http" {
  name        = "open-web-ui-http"
  description = local.http_sg_description
  vpc_id      = aws_vpc.open_web_ui.id
  ingress {
    description = local.http_ingress_description
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  egress {
    description = local.egress_description
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  tags = {
    Name        = "open-web-ui-http"
    description = local.http_sg_description
  }
}


resource "aws_key_pair" "open_web_ui" {
  key_name   = "open-web-ui"
  public_key = file("~/.ssh/open-web-ui-key.pub")
  tags = {
    Name        = "open-web-ui"
    description = local.key_pair_description
  }
}

resource "terracurl_request" "open_web_ui" {
  name           = "open-web-ui"
  url            = "http://${aws_spot_instance_request.open_web_ui.public_ip}"
  method         = "GET"
  response_codes = ["200"]
  max_retry      = 120
  retry_interval = 10
}

resource "aws_spot_instance_request" "open_web_ui" {
  ami                         = data.aws_ami.debian.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.open_web_ui.key_name
  vpc_security_group_ids      = [aws_security_group.open_web_ui_ssh.id, aws_security_group.open_web_ui_http.id]
  subnet_id                   = aws_subnet.open_web_ui.id
  wait_for_fulfillment        = true
  root_block_device {
    volume_size = 30
  }
  user_data_base64 = base64encode(templatefile("${path.module}/scripts/provision_vm.sh", {
    open_web_ui_user     = var.open_web_ui_user,
    open_web_ui_password = random_password.open_web_ui_password.result,
  }))
  tags = {
    Name        = "open-web-ui"
    description = local.spot_instance_description
  }
}
