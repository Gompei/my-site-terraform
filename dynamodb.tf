resource "aws_dynamodb_table" "main" {
  name           = "my-site-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "article_id"

  attribute {
    name = "article_id"
    type = "N"
  }
}
