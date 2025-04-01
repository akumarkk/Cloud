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
    profile = "etlcapgroup"
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

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
    comment = "Origin Access Identity for static website"
}

resource "aws_cloudfront_distribution" "clf_dist" {
    origin {
        domain_name = aws_s3_bucket.web_bucket.bucket_regional_domain_name
        origin_id = var.bucket_name
        s3_origin_config {
            origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
            
        }
    }
    enabled = true
    is_ipv6_enabled = true
    default_root_object = var.website_index_document

    default_cache_behavior {
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = var.bucket_name

        forwarded_values {
            query_string = false

            cookies {
                forward = "none"
            }

        }
        viewer_protocol_policy = "redirect-to-https"
        min_ttl = 0
        max_ttl = 86400
        default_ttl = 3600

    }

    viewer_certificate {
     cloudfront_default_certificate = true   
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
            
        }
    }

    tags = {
        Name = "Cloudfront dist"
        Environment = "Dev"
    }





}

resource "aws_s3_bucket_policy" "webssg_bucket_policy" {
    bucket = aws_s3_bucket.web_bucket.id
    policy = jsonencode(
        {
    "Version": "2012-10-17",
    "Statement": {
        "Sid": "AllowCloudFrontServicePrincipalReadWrite",
        "Effect": "Allow",
        "Principal": {
            CanonicalUser = aws_cloudfront_origin_access_identity.origin_access_identity.s3_canonical_user_id
        },
        "Action": [
            "s3:GetObject",
            "s3:PutObject"
        ],
        "Resource": "${aws_s3_bucket.web_bucket.arn}/*",
    }
}
    )
}