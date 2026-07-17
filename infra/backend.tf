terraform {
  backend "s3" {
    bucket         = "tf-state-bucket-5050"
    dynamodb_table = "terraform-state-lock"
    key            = "envs/dev/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}

