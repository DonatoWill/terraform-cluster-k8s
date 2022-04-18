resource "aws_vpc" "new_vpc"{
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "${var.prefix}-vpc"
    }
}

data "aws_availability_zones" "available" {}

# Cria duas subnets
resource "aws_subnet" "subnets" {
    availability_zone = data.aws_availability_zones.available.names[count.index]
    count = 2
    vpc_id = aws_vpc.new_vpc.id
    cidr_block = "10.0.${count.index}.0/24"
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.prefix}-subnet-${count.index}"
    }
}

resource "aws_internet_gateway" "new_internet_gateway" {
    vpc_id = aws_vpc.new_vpc.id
    tags = {
        Name = "${var.prefix}-igw"
    }
}

resource "aws_route_table" "new_route_table" {
    vpc_id = aws_vpc.new_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.new_internet_gateway.id
    }
    tags = {
      Name = "${var.prefix}-rtb"
    }
}

resource "aws_route_table_association" "new_route_table_association" {
    count = 2
    route_table_id = aws_route_table.new_route_table.id 
    subnet_id = aws_subnet.subnets.*.id[count.index]
}

# resource "aws_subnet" "new_subnet" {
#     vpc_id = aws_vpc.new_vpc.id
#     cidr_block = "10.0.1.0/24"
#     tags = {
#         Name = "${var.prefix}-subnet-1"
#     }
#     availability_zone = "us-east-1a"
# }

# resource "aws_subnet" "new_subnet-2" {
#     vpc_id = aws_vpc.new_vpc.id
#     cidr_block = "10.0.0.0/24"
#     tags = {
#         Name = "${var.prefix}-subnet-2"
#     }
#     availability_zone = "us-east-1b"
# }

