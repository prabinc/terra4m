locals {
  max_subnet_length = max(
    length(var.private_subnet_cidr),
    length(var.db_subnet_cidr)
  )
  common_tags = {
    Environment = terraform.workspace
    Project     = "${var.project}"
    Application = "${var.application}"
    ManagedBy   = "Terraform"
  }
}
resource "aws_vpc" "main" {
  cidr_block         = "${var.cidr_block}"
  enable_dns_support = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}" })
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}-ig" })
  )
}

######################################################################
## NAT GATEWAY
########################################################################

resource "aws_eip" "eip1" {
  vpc = true
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}-eip1" })
  )
}
resource "aws_eip" "eip2" {
  vpc = true
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}-eip2" })
  )
}


resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.eip1.id
  subnet_id = element(
    aws_subnet.public.*.id, 1)

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}-nat1"})
  )

  depends_on = [aws_internet_gateway.main]
}
resource "aws_nat_gateway" "nat2" {
  allocation_id = aws_eip.eip2.id
  subnet_id = element(
    aws_subnet.public.*.id, 2)

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}-nat2"})
  )

  depends_on = [aws_internet_gateway.main]
}
######################################################################
#Public Subnets
######################################################################
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    local.common_tags,
    var.public_eks_tag,
    tomap({ "Name" = "${var.prefix}-pub-${count.index}-${var.azs[count.index]}" })
  )
}
######################################################################
#Private Subnets
######################################################################
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    local.common_tags,
    var.private_eks_tag,
    tomap({ "Name" = "${var.prefix}-pvt-${count.index}-${var.azs[count.index]}" })
  )
}


######################################################################
#DataBase Subnets
######################################################################
resource "aws_subnet" "db" {
  count             = length(var.db_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnet_cidr[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}-db-${count.index}-${var.azs[count.index]}" })
  )
}
#################################################################################
#Route Tables, Route Table Association and Routes
#################################################################################

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}-public-rt" })
  )
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route" "public-internet-access" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}-private-rt" })
  )
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route" "route-nat-gateway1" {
  route_table_id         = aws_route_table.private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat1.id
}
resource "aws_route" "route-nat-gateway2" {
  route_table_id         = aws_route_table.private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat2.id
}

