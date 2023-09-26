locals {
  select            = (var.cidr == "" ? 1 : 0)
  create            = (var.cidr != "" ? 1 : 0)
  name              = var.name
  cidr              = var.cidr
  vpc_id            = var.vpc_id
  owner             = var.owner
  availability_zone = var.availability_zone
}

data "aws_subnet" "selected" {
  count = local.select
  filter {
    name   = "tag:Name"
    values = [local.name]
  }
}
resource "aws_subnet" "new" {
  count             = local.create
  vpc_id            = local.vpc_id
  cidr_block        = local.cidr
  availability_zone = local.availability_zone
  tags = {
    Name  = local.name
    Owner = local.owner
  }
}
