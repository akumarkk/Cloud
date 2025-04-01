variable "bucket_name" {
    default = "wsitessg_bucket_180"
    description = "Bucket for ssg site and poc!"
}

variable "website_index_document" {
    description = "Index page"
    default = "index.html"
}