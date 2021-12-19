########################################################
# Dynamodb Table
########################################################
resource "aws_dynamodb_table" "dynamodb_table" {
  name           = "article_table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"
  attribute {
    name = "id"
    type = "N"
  }
}
