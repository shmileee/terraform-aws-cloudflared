# ------------------------------------------------------------------------------
# Locals
# ------------------------------------------------------------------------------

locals {
  awslogs_group = var.logs_cloudwatch_group == "" ? "/ecs/${var.environment}/${var.name_prefix}" : var.logs_cloudwatch_group
  default_container_definitions = jsonencode(
    [

      {
        name  = var.name_prefix
        image = var.docker_image

        cpu       = 256
        memory    = 512
        essential = true

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = local.awslogs_group
            "awslogs-region"        = data.aws_region.current.name
            "awslogs-stream-prefix" = "default"
          }
        }
        environment = [
          {
            "name" : "S3_CERT_PEM",
            "value" : var.s3_cert_path
          },
          {
            "name" : "TUNNEL_URL",
            "value" : var.tunnel_url
          },
          {
            "name" : "TUNNEL_HOSTNAME",
            "value" : var.tunnel_hostname
          }
        ]
        mountPoints = []
        volumesFrom = []
      }
    ]
  )
}
