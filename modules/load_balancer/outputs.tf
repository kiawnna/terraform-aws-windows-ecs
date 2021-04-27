output "load_balancer_arn" {
  value = aws_lb.ALB.arn
}
output "load_balancer_id" {
  value = aws_lb.ALB.id
}
output "lb_dns_name" {
  value = aws_lb.ALB.dns_name
}
output "lb_zone_id" {
  value = aws_lb.ALB.id
}
output "listener_443_arn" {
  value = aws_lb_listener.https.arn
}