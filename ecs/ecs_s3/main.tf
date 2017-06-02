provider "aws" {
  region = "${var.region}"
}

resource "aws_s3_bucket" "clivisui-state" {
  bucket = "mskvb0-clivisui-state"
  acl    = "private"

  tags {
    Name        = "clivisui-state"
    Environment = "Experiment"
  }

  versioning {
    enabled = true
  }
}
