resource "aws_iam_user" "this" {
  count = var.create_user ? 1 : 0

  name                 = var.name
  path                 = var.path
  force_destroy        = var.force_destroy
  permissions_boundary = var.permissions_boundary

  tags = var.tags
}

resource "aws_iam_user_login_profile" "this" {
  count = var.create_user && var.create_iam_user_login_profile ? 1 : 0

  user                    = aws_iam_user.this[0].name
  pgp_key                 = var.pgp_key
  password_length         = var.password_length
  password_reset_required = var.password_reset_required

  # TODO: Remove once https://github.com/hashicorp/terraform-provider-aws/issues/23567 is resolved
  lifecycle {
    ignore_changes = [
      password_reset_required,
      password_length,
      pgp_key
    ]
  }
}

resource "aws_iam_access_key" "this" {
  count = var.create_user && var.create_iam_access_key && var.pgp_key != "" ? 1 : 0

  user    = aws_iam_user.this[0].name
  pgp_key = var.pgp_key
}

resource "aws_iam_access_key" "this_no_pgp" {
  count = var.create_user && var.create_iam_access_key && var.pgp_key == "" ? 1 : 0

  user = aws_iam_user.this[0].name
}

resource "aws_iam_user_ssh_key" "this" {
  count = var.create_user && var.upload_iam_user_ssh_key ? 1 : 0

  username   = aws_iam_user.this[0].name
  encoding   = var.ssh_key_encoding
  public_key = var.ssh_public_key
}


resource "aws_ssm_parameter" "this" {
  count = var.create_user && var.create_iam_user_login_profile ? 1 : 0

  name        = "/team/${var.team}/iam/${aws_iam_user.this[0].name}/password"
  description = "The base64 encoded IAM password for user ${aws_iam_user.this[0].name}"
  type        = "SecureString"
  value       = (aws_iam_user_login_profile.this[0].encrypted_password != null) ? base64decode(aws_iam_user_login_profile.this[0].encrypted_password) : aws_iam_user_login_profile.this[0].password

}
