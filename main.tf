# ------------------------------------------------------------------------------
# Resources
# ------------------------------------------------------------------------------

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

resource "aws_ecs_cluster" "tunnels" {
  name = var.name_prefix

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# We want to use a KMS key to encrypt our Cloudwatch logs for this
# service; this keeps the logs encrypted at rest on disk. As a rule, we
# always want to use encryption like this where we can.
#
# This sets up a policy that lets Cloudwatch logs actually use our KMS
# keys and then creates a key to use for encrypting these logs.

data "aws_iam_policy_document" "cloudwatch_logs_allow_kms" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }

    actions = [
      "kms:*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow logs KMS access"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key" "main" {
  description         = "Key for ECS log encryption"
  enable_key_rotation = true

  policy = data.aws_iam_policy_document.cloudwatch_logs_allow_kms.json
}

resource "aws_cloudwatch_log_group" "main" {
  name              = local.awslogs_group
  retention_in_days = 7
  kms_key_id        = aws_kms_key.main.arn

  tags = {
    Name        = "${var.environment}-${var.name_prefix}"
    Environment = var.environment
    Automation  = "Terraform"
  }
}

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "task_execution_role_policy_doc" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["${aws_cloudwatch_log_group.main.arn}:*"]
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]

    resources = var.ecr_repo_arns
  }
}

data "aws_iam_policy_document" "task_role_policy_doc" {
  statement {
    actions = [
      "s3:*",
    ]
    resources = [
      "${var.s3_bucket_arn}/*",
      "${var.s3_bucket_arn}",
    ]
  }
  statement {
    actions = [
      "s3:ListAllMyBuckets"
    ]
    resources = [var.s3_bucket_arn]
  }
}

resource "aws_iam_role" "task_role" {
  name               = "ecs-task-role-${var.name_prefix}"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role" "task_execution_role" {
  count              = var.ecs_use_fargate ? 1 : 0
  name               = "ecs-task-execution-role-${var.name_prefix}"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role_policy" "task_execution_role_policy" {
  count  = var.ecs_use_fargate ? 1 : 0
  name   = "${aws_iam_role.task_execution_role[0].name}-policy"
  role   = aws_iam_role.task_execution_role[0].name
  policy = data.aws_iam_policy_document.task_execution_role_policy_doc.json
}

resource "aws_iam_role_policy" "task_role_policy" {
  count  = var.ecs_use_fargate ? 1 : 0
  name   = "${aws_iam_role.task_role.name}-policy"
  role   = aws_iam_role.task_role.name
  policy = data.aws_iam_policy_document.task_role_policy_doc.json
}

resource "aws_ecs_task_definition" "main" {
  family        = var.name_prefix
  network_mode  = "awsvpc"
  task_role_arn = aws_iam_role.task_role.arn

  # Fargate requirements
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = join("", aws_iam_role.task_execution_role.*.arn)

  container_definitions = var.container_definitions == "" ? local.default_container_definitions : var.container_definitions
}

resource "aws_ecs_service" "tunnel" {
  name             = var.name_prefix
  cluster          = aws_ecs_cluster.tunnels.id
  task_definition  = aws_ecs_task_definition.main.arn
  desired_count    = var.tasks_desired_count
  launch_type      = "FARGATE"
  platform_version = "LATEST"
  depends_on       = [aws_iam_role_policy.task_execution_role_policy]

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = compact(concat(tolist([aws_security_group.ecs_sg[0].id])))
    assign_public_ip = var.assign_public_ip
  }
}

resource "aws_security_group" "ecs_sg" {
  count       = var.manage_ecs_security_group ? 1 : 0
  name        = "ecs-${var.name_prefix}"
  description = "ecs ${var.name_prefix} container security group"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "app_ecs_allow_outbound" {
  count             = var.manage_ecs_security_group ? 1 : 0
  description       = "All outbound"
  security_group_id = aws_security_group.ecs_sg[0].id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
