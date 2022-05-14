# ---------------------------------------------------------------------------------------------------------------------
# BASIC TERRAFORM CONTENT EXAMPLE
# ---------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

module "tunnel" {
  source = "../../"

  name_prefix = "my-tunnel"
  environment = "prod"

  tunnel_url      = "https://my.private.service.endpoint.com"
  tunnel_hostname = "my.internal.company.net"

  s3_bucket_arn = "arn:aws:s3:::my-bucket"
  s3_cert_path  = "s3://my-bucket/cert.pem"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
}
