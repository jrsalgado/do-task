output "bastion-dns" {
  value = aws_lb.bastion.dns_name
}
