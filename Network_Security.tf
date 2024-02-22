# Define provider & region
provider "aws" {
  region = "eu-central-1" 
}

# Define a security group
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "This SG will be used for controlling network traffic"
  vpc_id = "vpc-0d84b6be205e562f0" 
}

# Define a network ACL
resource "aws_network_acl" "web_acl" {
  vpc_id = "vpc-0d84b6be205e562f0"  

  # Define ingress (inbound) rules
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
  }

  # Define egress (outbound) rules
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    rule_action = "allow"
    cidr_block  = "0.0.0.0/0"
  }
}

# Define a web-ACL (firewall usage) using AWS WAF
resource "aws_waf_web_acl" "my_waf_acl" {
  name        = "my-web-acl"
  metric_name = "myWebACL"

  default_action {
    type = "BLOCK"
  }

  ip_set_descriptors {
    type  = "IPV4"
    value = "192.0.7.0/24"
  }
}

resource "aws_waf_rule" "wafrule" {
  depends_on  = [aws_waf_ipset.ipset]
  name        = "tfWAFRule"
  metric_name = "tfWAFRule"

  predicates {
    data_id = aws_waf_ipset.ipset.id
    negated = false
    type    = "IPMatch"
  }
  

  # Define rules (e.g., block requests from certain IP addresses)
  rule {
    name        = "my-rule"
    priority    = 1
    action {
      type = "BLOCK"
    }
    statement {
      ip_set_reference_statement {
        arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/IPSet-12345678"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled  = true
      metric_name                = "exampleRuleMetric"
    }
  }
}
