output "s3_bucket_name" {
    value = aws_s3_bucket.web_bucket.id
}

output "cloudfront_distribution_domain_name" {
    value = aws_cloudfront_distribution.clf_dist.domain_name
}