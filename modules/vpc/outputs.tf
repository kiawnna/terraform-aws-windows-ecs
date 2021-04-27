output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "subnet_id1" {
  value = aws_subnet.public-1.id
}
output "subnet_id2" {
  value = aws_subnet.public-2.id
}
output "subnet_id3" {
  value = aws_subnet.public-3.id
}
output "private_subnet_id" {
  value = aws_subnet.private_1.id
}
output "private_subnet_id2" {
  value = aws_subnet.private_2.id
}
output "private_subnet_id3" {
  value = aws_subnet.private_3.id
}
output "internet_gateway" {
  value = aws_internet_gateway.internet-gateway.id
}
