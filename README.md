# AWS Identity and Access Management (IAM) Terraform module


## Features

1. **Cross-account access.** Define IAM roles using `iam_assumable_role` or `iam_assumable_roles` submodules in "resource AWS accounts (prod, staging, dev)" and IAM groups and users using `iam-group-with-assumable-roles-policy` submodule in "IAM AWS Account" to setup access controls between accounts. 
2. **Individual IAM resources (users, roles, policies).** 

## Usage

`aws-iam-account`:

```hcl
module "iam_account" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-account"
  version = "~> 4"

  account_alias = "awesome-company"

  minimum_password_length = 37
  require_numbers         = false
}
```

`aws-iam-user`:

```hcl
module "iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "~> 4"

  name          = "vasya.pupkin"
  force_destroy = true

  pgp_key = "keybase:test"

  password_reset_required = false
}
```

`aws-iam-group-with-assumable-roles-policy`:

```hcl
module "iam_group_with_assumable_roles_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-assumable-roles-policy"
  version = "~> 4"

  name = "production-readonly"

  assumable_roles = [
    "arn:aws:iam::835367859855:role/readonly"  # these roles can be created using `iam_assumable_roles` submodule
  ]

  group_users = [
    "user1",
    "user2"
  ]
}
```

`aws-iam-group-with-policies`:

```hcl
module "iam_group_with_policies" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "~> 4"

  name = "superadmins"

  group_users = [
    "user1",
    "user2"
  ]

  attach_iam_self_management_policy = true

  custom_group_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]

  custom_group_policies = [
    {
      name   = "AllowS3Listing"
      policy = data.aws_iam_policy_document.sample.json
    }
  ]
}
```

`aws-iam-policy`:

```hcl
module "iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 4"

  name        = "example"
  path        = "/"
  description = "My example policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
```

`aws-iam-read-only-policy`:

```hcl
module "iam_read_only_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-read-only-policy"
  version = "~> 4"

  name        = "example"
  path        = "/"
  description = "My example read-only policy"

  allowed_services = ["rds", "dynamo", "health"]
}
```

## AWS IAM Best Practices

AWS published [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html) and this Terraform module was created to help with some of points listed there:

### 1. Create Individual IAM Users
