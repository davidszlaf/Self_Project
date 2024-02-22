provider "aws" {
  region = "eu-central-1"  
}

# IAM policy for read-only access to S3
data "aws_iam_policy_document" "s3_read_policy" {
  statement {
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = ["arn:aws:s3:::mt-bucket/*", "arn:aws:s3:::my-bucket"]
  }
}

# IAM policy allowing read-only access to S3 buckets
resource "aws_iam_policy" "s3_read_policy" {
  name        = "s3-read-only-policy"
  description = "Policy allowing read-only access to S3 buckets"
  policy      = data.aws_iam_policy_document.s3_read_policy.json
}

# Create the IAM group
resource "aws_iam_group" "developers" {
  name = "developers"
}

# Attach IAM policy to the IAM group
resource "aws_iam_group_policy_attachment" "s3_read_attachment" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

# Create an IAM user
resource "aws_iam_user" "developer" {
  name = "developer"
}

# Add the IAM user to the IAM group
resource "aws_iam_user_group_membership" "developer_membership" {
  user  = aws_iam_user.developer.name
  groups = [aws_iam_group.developers.name]
}
