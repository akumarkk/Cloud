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
    bucket = aws_s3_bucket.web_bucket.id
    key = "index.html"
    source = "sitessg/index.html"
    etag = filemd5("sitessg/index.html")
    content_type= "text/html"

}

resource "aws_s3_object" "error_html" {
    bucket = aws_s3_bucket.web_bucket.id
    key = "error.html"
    source = "sitessg/error.html"
    etag = filemd5("sitessg/error.html")
    content_type= "text/html"
}