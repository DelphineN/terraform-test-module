module "iam-user1" {
  source        = "../test-module/module/iam-user"
  name          = "user-1"
  force_destroy = true

  create_iam_user_login_profile = false
  create_iam_access_key         = true
}

module "iam-user2" {
  source        = "../test-module/module/iam-user"
  name          = "user-2"
  force_destroy = true

  create_iam_user_login_profile = false
  create_iam_access_key         = true

}

module "iam-user3" {
  source        = "../test-module/module/iam-user"
  name          = "businessanalysts"
  force_destroy = true

  create_iam_user_login_profile = false
  create_iam_access_key         = true

}

module "iam-group" {
  source = "../test-module/module/iam-group"
  name   = "superadmins"

  group_users = [
    module.iam-user1.iam_user_name
  ]

  custom_group_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]
}


module "iam-group-developer-policy" {
  source = "../test-module/module/iam-group"
  name   = "Developer"

  group_users = [
    module.iam-user2.iam_user_name,
    module.iam-user1.iam_user_name,
  ]

  custom_group_policy_arns = [
    "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess",
    "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access",
  ]
}


module "iam-group-ProjectManager-policy" {
  source = "../test-module/module/iam-group"
  name   = "ProjectManager"

  group_users = [
    module.iam-user3.iam_user_name
  ]

  custom_group_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
  ]

  custom_group_policies = [
    {
      name   = "AmazonEC2ReadOnlyAccess"
      policy = data.aws_iam_policy_document.PM.json
    },
  ]
}


######################
# IAM policy
######################
data "aws_iam_policy_document" "PM" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:Describe*",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:Describe*",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "autoscaling:Describe*",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:Describe*",
    ]

    resources = ["*"]
  }
}