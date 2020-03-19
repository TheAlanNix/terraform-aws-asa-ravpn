provider "aws" {
  region     = var.region
}

/*
  Create VPC
 */
resource "aws_vpc" "main" {
  cidr_block = var.vpc_subnet

  tags = {
    "Name" = var.vpc_name
  }
}

/*
  Create Internet Gateway
 */
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "${var.vpc_name} Internet Gateway"
  }
}

/*
  Create Transit Gateway
 */
resource "aws_ec2_transit_gateway" "transit_gateway" {
  count = (var.transit_gateway_id == "" ? 1 : 0)

  description = "ASAv_RAVPN_TG"
}

/*
  Create Subnets
 */
resource "aws_subnet" "outside_subnets" {
  count = var.availability_zone_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_subnet, 8, (var.availability_zone_count + 1) * count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name" = "${var.vpc_name} Outside Subnet ${count.index + 1}"
  }
}
resource "aws_subnet" "inside_subnets" {
  count = var.availability_zone_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_subnet, 8, ((var.availability_zone_count + 1) * count.index) + 1)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name" = "${var.vpc_name} Inside Subnet ${count.index + 1}"
  }
}
resource "aws_subnet" "management_subnets" {
  count = var.availability_zone_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_subnet, 8, ((var.availability_zone_count + 1) * count.index) + 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name" = "${var.vpc_name} Management Subnet ${count.index + 1}"
  }
}

/*
  Create "RAVPN" Security Group
 */
resource "aws_security_group" "allow_ravpn" {
  name        = "Allow RAVPN"
  description = "Security Group to allow RAVPN traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "Allow RAVPN"
  }
}

/*
  Create "Allow Internal Networks" Security Group
 */
resource "aws_security_group" "allow_internal_networks" {
  name        = "Allow Internal Networks"
  description = "Security Group to allow internal traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.internal_networks
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "Allow Internal Networks"
  }
}

/*
  Create "Allow SSH" Security Group
 */
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = var.internal_networks
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.internal_networks
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "Allow SSH"
  }
}

/*
  Create Network Interfaces
 */
resource "aws_network_interface" "management_interfaces" {
  count = var.availability_zone_count * var.instances_per_az

  subnet_id         = aws_subnet.management_subnets[floor(count.index / var.instances_per_az)].id
  security_groups   = [aws_default_security_group.default.id]
  source_dest_check = false

  tags = {
    "Name" = "ASAv Management Interface ${count.index + 1}"
  }
}
resource "aws_network_interface" "outside_interfaces" {
  count = var.availability_zone_count * var.instances_per_az

  subnet_id         = aws_subnet.outside_subnets[floor(count.index / var.instances_per_az)].id
  security_groups   = [aws_security_group.allow_ravpn.id]
  source_dest_check = false

  tags = {
    "Name" = "ASAv Outside Interface ${count.index + 1}"
  }
}
resource "aws_network_interface" "inside_interfaces" {
  count = var.availability_zone_count * var.instances_per_az

  subnet_id         = aws_subnet.inside_subnets[floor(count.index / var.instances_per_az)].id
  security_groups   = [aws_security_group.allow_internal_networks.id]
  source_dest_check = false

  tags = {
    "Name" = "ASAv Inside Interface ${count.index + 1}"
  }
}

/*
  Create EIPs
 */
resource "aws_eip" "outside_eips" {
  count = var.availability_zone_count * var.instances_per_az

  vpc        = true
  depends_on = [aws_internet_gateway.internet_gateway]

  tags = {
    "Name" = "ASAv Outside IP ${count.index + 1}"
  }
}
resource "aws_eip_association" "outside_eip_association" {
  count = var.availability_zone_count * var.instances_per_az

  network_interface_id = aws_network_interface.outside_interfaces[count.index].id
  allocation_id        = aws_eip.outside_eips[count.index].id
}
resource "aws_eip" "nat_gateway_eips" {
  count = var.availability_zone_count

  vpc        = true
  depends_on = [aws_internet_gateway.internet_gateway]

  tags = {
    "Name" = "ASAv Management NAT ${count.index + 1}"
  }
}

/*
  Create NAT Gateway
 */
resource "aws_nat_gateway" "management_nat_gateway" {
  count = var.availability_zone_count

  allocation_id = aws_eip.nat_gateway_eips[count.index].id
  subnet_id     = aws_subnet.outside_subnets[count.index].id
  depends_on    = [aws_internet_gateway.internet_gateway]

  tags = {
    "Name" = "ASAv Management NAT Gateway ${count.index + 1}"
  }
}

/*
  Create Transit Gateway Attachment
 */
resource "aws_ec2_transit_gateway_vpc_attachment" "example" {
  subnet_ids         = [for subnet in aws_subnet.inside_subnets: subnet.id]
  transit_gateway_id = (var.transit_gateway_id != "" ?  var.transit_gateway_id : aws_ec2_transit_gateway.transit_gateway[0].id)
  vpc_id             = aws_vpc.main.id

  tags = {
    "Name" = "RAVPN_VPC_TO_TRANSIT_GATEWAY"
  }
}

/*
  Create Outside Route Table
 */
resource "aws_route_table" "route_table_outside" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "${var.vpc_name} Outside Route Table"
  }
}
resource "aws_route" "default_route" {
  route_table_id          = aws_route_table.route_table_outside.id
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = aws_internet_gateway.internet_gateway.id
}
resource "aws_route_table_association" "route_table_association_outside" {
  count = length(aws_subnet.outside_subnets)

  subnet_id      = aws_subnet.outside_subnets[count.index].id
  route_table_id = aws_route_table.route_table_outside.id
}

/*
  Create Inside Route Table
 */
resource "aws_route_table" "route_table_inside" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "${var.vpc_name} Inside Route Table"
  }
}
resource "aws_route" "inside_internal_routes" {
  count = length(var.internal_networks)

  route_table_id          = aws_route_table.route_table_inside.id
  destination_cidr_block  = var.internal_networks[count.index]
  transit_gateway_id      = (var.transit_gateway_id != "" ?  var.transit_gateway_id : aws_ec2_transit_gateway.transit_gateway[0].id)
}
resource "aws_route_table_association" "route_table_association_inside" {
  count = length(aws_subnet.inside_subnets)

  subnet_id      = aws_subnet.inside_subnets[count.index].id
  route_table_id = aws_route_table.route_table_inside.id
}

/*
  Create Management Route Table
 */
resource "aws_route_table" "management_route_tables" {
  count = var.availability_zone_count

  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.management_nat_gateway[count.index].id
  }

  tags = {
    "Name" = "${var.vpc_name} Management Route Table ${count.index + 1}"
  }
}
resource "aws_route" "management_internal_routes" {
  count = var.availability_zone_count * length(var.internal_networks)

  route_table_id          = aws_route_table.management_route_tables[floor(count.index / length(var.internal_networks))].id
  destination_cidr_block  = var.internal_networks[count.index % length(var.internal_networks)]
  transit_gateway_id      = (var.transit_gateway_id != "" ?  var.transit_gateway_id : aws_ec2_transit_gateway.transit_gateway[0].id)
}
resource "aws_route_table_association" "route_rable_association_management" {
  count = length(aws_subnet.management_subnets)

  subnet_id      = aws_subnet.management_subnets[count.index].id
  route_table_id = aws_route_table.management_route_tables[count.index].id
}

/*
  Fiters to get the most recent BYOL ASAv image
 */
data "aws_ami" "cisco_asa_lookup" {
  most_recent = true

  filter {
    name   = "product-code"
    values = ["663uv4erlxz65quhgaz9cida0"]
  }

  owners = ["679593333241"]
}

/*
  Generate a random password
 */
resource "random_password" "password" {
  length  = 20
  special = true

  provisioner "local-exec" {
    command = "echo \"${random_password.password.result}\" > password.txt"
  }
}

/*
  Set up the ASA configuration file
 */
data "template_file" "asa_config" {
  count = var.availability_zone_count * var.instances_per_az

  depends_on = [random_password.password, aws_subnet.inside_subnets]
  template   = "${file("asa_config_template.txt")}"

  vars = {
    asa_password           = random_password.password.result
    default_gateway_inside = cidrhost(aws_subnet.inside_subnets[floor(count.index / var.instances_per_az)].cidr_block, 1)
    throughput_level       = lookup(var.throughput_level, var.instance_size, "1G")
  }
}
 
/*
  Create ASAv Instance
 */
resource "aws_instance" "asav" {
  count = var.availability_zone_count * var.instances_per_az

  ami           = data.aws_ami.cisco_asa_lookup.id
  instance_type = var.instance_size
  tags          = {
    Name = "Cisco ASAv RAVPN ${count.index + 1}"
  }

  user_data = data.template_file.asa_config[count.index].rendered

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.management_interfaces[count.index].id
  }

  network_interface {
    device_index = 1
    network_interface_id = aws_network_interface.outside_interfaces[count.index].id
  }

  network_interface {
    device_index = 2
    network_interface_id = aws_network_interface.inside_interfaces[count.index].id
  }
}

output "inside_ips" {
  value = aws_network_interface.inside_interfaces.*.private_ip
}
output "management_ips" {
  value = aws_network_interface.management_interfaces.*.private_ip
}
output "outside_ips" {
  value = aws_eip.outside_eips.*.public_ip
}
