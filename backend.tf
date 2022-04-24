terraform {
  backend "s3" {
    bucket         = "tf-aws-terrafom-state"
    key            = "tfstates/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "tf_aws_lock_table"
    encrypt        = true
  }
}