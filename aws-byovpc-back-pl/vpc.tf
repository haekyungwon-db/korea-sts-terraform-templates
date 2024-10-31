data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name = local.prefix
  cidr = var.cidr_block
  azs  = data.aws_availability_zones.available.names
  tags = var.tags

  enable_dns_hostnames = true
  enable_nat_gateway   = false
  create_igw           = false

  public_subnets = [cidrsubnet(var.cidr_block, 3, 0),cidrsubnet(var.cidr_block, 3, 2)]
  private_subnets = [cidrsubnet(var.cidr_block, 3, 1),cidrsubnet(var.cidr_block, 3, 3)]

  manage_default_security_group = true
  default_security_group_name   = "${local.prefix}-sg"

  default_security_group_egress = [
    {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 6666
      to_port = 6666
      protocol = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 8443
      to_port = 8451
      protocol = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      self = true
      from_port = 0
      to_port = 65535
      protocol = "tcp"
    },
    {
      self = true
      from_port = 0
      to_port = 65535
      protocol = "udp"
    }
  ]

  default_security_group_ingress = [
    {
      self = true
      from_port = 0
      to_port = 65535
      protocol = "tcp"
    },
    {
      self = true
      from_port = 0
      to_port = 65535
      protocol = "udp"
    }
  ]
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.2.0"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.vpc.default_security_group_id]

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      route_table_ids = flatten([
        module.vpc.private_route_table_ids
      ])
      tags = {
        Name = "${local.prefix}-s3-vpc-endpoint"
      }
    },
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags = {
        Name = "${local.prefix}-sts-vpc-endpoint"
      }
    },
    kinesis-streams = {
      service             = "kinesis-streams"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags = {
        Name = "${local.prefix}-kinesis-vpc-endpoint"
      }
    },
  }

  tags = var.tags
}

resource "aws_subnet" "dataplane_vpce" {
  vpc_id     = module.vpc.vpc_id
  cidr_block = var.vpce_subnet_cidr
  tags = {
    Name = "${local.prefix}-vpce-subnet"
  }
}

resource "aws_route_table" "vpce_route_table" {
  vpc_id = module.vpc.vpc_id
}

resource "aws_route_table_association" "dataplane_vpce_rtb" {
  subnet_id      = aws_subnet.dataplane_vpce.id
  route_table_id = aws_route_table.vpce_route_table.id
}

resource "aws_security_group" "dataplane_vpce" {
  name        = "Data Plane VPC endpoint security group"
  description = "Security group shared with relay and workspace endpoints"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = toset([
      443,
      2443, # FIPS port for CSP
      6666,
    ])

    content {
      description = "Inbound rules"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.cidr_block]
    }
  }

  dynamic "egress" {
    for_each = toset([
      443,
      2443, # FIPS port for CSP
      6666,
    ])

    content {
      description = "Outbound rules"
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = [var.cidr_block]
    }
  }
}

resource "aws_vpc_endpoint" "backend_rest" {
  vpc_id              = module.vpc.vpc_id
  service_name        = var.workspace_vpce_service
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.dataplane_vpce.id]
  subnet_ids          = [aws_subnet.dataplane_vpce.id]
  private_dns_enabled = var.private_dns_enabled
  depends_on          = [aws_subnet.dataplane_vpce]
}

resource "aws_vpc_endpoint" "relay" {
  vpc_id              = module.vpc.vpc_id
  service_name        = var.relay_vpce_service
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.dataplane_vpce.id]
  subnet_ids          = [aws_subnet.dataplane_vpce.id]
  private_dns_enabled = var.private_dns_enabled
  depends_on          = [aws_subnet.dataplane_vpce]
}

resource "databricks_mws_vpc_endpoint" "backend_rest_vpce" {
  provider            = databricks.mws
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = aws_vpc_endpoint.backend_rest.id
  vpc_endpoint_name   = "${local.prefix}-vpc-backend"
  region              = var.region
  depends_on          = [aws_vpc_endpoint.backend_rest]
}

resource "databricks_mws_vpc_endpoint" "relay" {
  provider            = databricks.mws
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = aws_vpc_endpoint.relay.id
  vpc_endpoint_name   = "${local.prefix}-vpc-relay"
  region              = var.region
  depends_on          = [aws_vpc_endpoint.relay]
}

resource "databricks_mws_networks" "this" {
  provider           = databricks.mws
  account_id         = var.databricks_account_id
  network_name       = "${local.prefix}-network"
  security_group_ids = [module.vpc.default_security_group_id]
  subnet_ids         = module.vpc.private_subnets
  vpc_id             = module.vpc.vpc_id
  vpc_endpoints {
    dataplane_relay = [databricks_mws_vpc_endpoint.relay.vpc_endpoint_id]
    rest_api        = [databricks_mws_vpc_endpoint.backend_rest_vpce.vpc_endpoint_id]
  }
  depends_on          = [databricks_mws_vpc_endpoint.relay]
}
