# terraform-aws-cloudflared

[![latest release](https://img.shields.io/github/v/release/shmileee/terraform-aws-cloudflared?style=flat-square)](https://github.com/shmileee/terraform-aws-cloudflared/releases/latest)
[![build status](https://img.shields.io/github/workflow/status/shmileee/terraform-aws-cloudflared/workflow?label=build&logo=github&style=flat-square)](https://github.com/shmileee/terraform-aws-cloudflared/actions?query=workflow%3Atest)

Terraform module which creates Cloudflare Zero Trust tunnel on AWS running as a
ECS container:

* Runs an ECS service
* Stream logs to a CloudWatch log group encrypted with a KMS key
* Supports running ECS tasks on Fargate

## Usage

```hcl
module "tunnel" {
  source = "shmileee/cloudflared/aws"

  name_prefix = "my-tunnel"
  environment = "prod"

  tunnel_url      = "https://my.private.service.endpoint.com"
  tunnel_hostname = "my.internal.company.net"

  s3_bucket_arn =  "<s3 bucket arn>"
  s3_cert_path  = "s3://my-bucket/cert.pem"

  vpc_id     = local.vpc_id
  subnet_ids = local.public_subnets
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.70 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.70 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.tunnels](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.tunnel](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.task_execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.task_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_security_group.ecs_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.app_ecs_allow_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cloudwatch_logs_allow_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_execution_role_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_role_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Whether this instance should be accessible from the public internet. Default is false. | `bool` | `true` | no |
| <a name="input_container_definitions"></a> [container\_definitions](#input\_container\_definitions) | Container definitions provided as valid JSON document. Default uses shmileee/cloudflared-tunnel:latest | `string` | `""` | no |
| <a name="input_docker_image"></a> [docker\_image](#input\_docker\_image) | Full name of the Docker image to be used by ECS task. | `string` | `"docker.io/shmileee/cloudflared-tunnel:latest"` | no |
| <a name="input_ecr_repo_arns"></a> [ecr\_repo\_arns](#input\_ecr\_repo\_arns) | The ARNs of the ECR repos. By default, allows all repositories. | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_ecs_use_fargate"></a> [ecs\_use\_fargate](#input\_ecs\_use\_fargate) | Whether to use Fargate for the task definition. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment tag, e.g prod. | `string` | n/a | yes |
| <a name="input_logs_cloudwatch_group"></a> [logs\_cloudwatch\_group](#input\_logs\_cloudwatch\_group) | CloudWatch log group to create and use. Default: /ecs/{environment}/{name\_prefix} | `string` | `""` | no |
| <a name="input_manage_ecs_security_group"></a> [manage\_ecs\_security\_group](#input\_manage\_ecs\_security\_group) | Enable creation and management of the ECS security group and rules | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix used for naming resources. | `string` | `"cloudflared-tunnel"` | no |
| <a name="input_s3_bucket_arn"></a> [s3\_bucket\_arn](#input\_s3\_bucket\_arn) | ARN for S3 bucket where Cloudflare certificate is stored. | `string` | `null` | no |
| <a name="input_s3_cert_path"></a> [s3\_cert\_path](#input\_s3\_cert\_path) | Full path to where Cloudflare certificate is stored, e.g. s3://my-bucket/cert.pem | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs for the ECS tasks. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags (key-value pairs) passed to resources. | `map(string)` | `{}` | no |
| <a name="input_tasks_desired_count"></a> [tasks\_desired\_count](#input\_tasks\_desired\_count) | The number of instances of a task definition. | `number` | `1` | no |
| <a name="input_tunnel_hostname"></a> [tunnel\_hostname](#input\_tunnel\_hostname) | User friendly hostname of the tunnel, e.g. test.internal.example.com | `string` | n/a | yes |
| <a name="input_tunnel_url"></a> [tunnel\_url](#input\_tunnel\_url) | URL where cloudflared tunnel should point to. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to be used by ECS. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name_prefix"></a> [name\_prefix](#output\_name\_prefix) | n/a |
| <a name="output_tags"></a> [tags](#output\_tags) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Oleksandr Ponomarov.

## License

MIT License. See [LICENSE](LICENSE) for full details.
