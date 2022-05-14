# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

variable "name_prefix" {
  description = "A prefix used for naming resources."
  type        = string
  default     = "cloudflared-tunnel"
}

variable "environment" {
  description = "Environment tag, e.g prod."
  type        = string
}

variable "docker_image" {
  description = "Full name of the Docker image to be used by ECS task."
  type        = string
  default     = "docker.io/shmileee/cloudflared-tunnel:latest"
}

variable "tunnel_url" {
  description = "URL where cloudflared tunnel should point to."
  type        = string
}

variable "tunnel_hostname" {
  description = "User friendly hostname of the tunnel, e.g. test.internal.example.com"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN for S3 bucket where Cloudflare certificate is stored."
  type        = string
  default     = null
}

variable "s3_cert_path" {
  description = "Full path to where Cloudflare certificate is stored, e.g. s3://my-bucket/cert.pem"
  type        = string
  default     = null
}

variable "ecs_use_fargate" {
  description = "Whether to use Fargate for the task definition."
  default     = true
  type        = bool
}

variable "tasks_desired_count" {
  description = "The number of instances of a task definition."
  default     = 1
  type        = number
}

variable "assign_public_ip" {
  description = "Whether this instance should be accessible from the public internet. Default is false."
  default     = true
  type        = bool
}

variable "manage_ecs_security_group" {
  description = "Enable creation and management of the ECS security group and rules"
  default     = true
  type        = bool
}

variable "vpc_id" {
  description = "VPC ID to be used by ECS."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the ECS tasks."
  type        = list(string)
}

variable "container_definitions" {
  description = "Container definitions provided as valid JSON document. Default uses shmileee/cloudflared-tunnel:latest"
  default     = ""
  type        = string
}

variable "logs_cloudwatch_group" {
  description = "CloudWatch log group to create and use. Default: /ecs/{environment}/{name_prefix}"
  default     = ""
  type        = string
}

variable "ecr_repo_arns" {
  description = "The ARNs of the ECR repos. By default, allows all repositories."
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "A map of tags (key-value pairs) passed to resources."
  type        = map(string)
  default     = {}
}
