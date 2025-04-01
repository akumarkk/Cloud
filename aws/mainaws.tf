terraform{
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version= "5.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "web_bucket" {
    bucket = var.bucket_name #"ai_bucket"
}

resource "aws_s3_object" "index_html" {
    bucket = aws_s3_bucket.web_bucket
}