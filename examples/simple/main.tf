# ---------------------------------------------------------------------------------------------------------------------
# BASIC TERRAFORM CONTENT EXAMPLE
# ---------------------------------------------------------------------------------------------------------------------

module "ecr" {
  source  = "cloudposse/ecr/aws"
  version = "0.34.0"

  image_tag_mutability = "MUTABLE"
  namespace            = "example"
  image_names = [
    "cloudflared-tunnel",
  ]
}

module "tunnel" {
  source = "../../"

  name_prefix = "my-tunnel"
  environment = "prod"

  ecr_repo_arns = [module.ecr.repository_arn_map["cloudflared-tunnel"]]
  docker_image  = "${module.ecr.repository_url_map["cloudflared-tunnel"]}:latest"

  tunnel_url      = "https://my.private.service.endpoint.com"
  tunnel_hostname = "my.internal.company.net"

  s3_bucket_arn = module.packages.artifacts_bucket_arn
  s3_cert_path  = "s3://my-bucket/cert.pem"

  vpc_id     = local.vpc_id
  subnet_ids = local.public_subnets
}
