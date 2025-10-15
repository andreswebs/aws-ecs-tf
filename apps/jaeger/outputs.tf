output "dns_name" {
  value = aws_route53_record.this.fqdn
}
