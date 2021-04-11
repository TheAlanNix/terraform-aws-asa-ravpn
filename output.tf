output "inside_ips" {
  value       = aws_network_interface.inside_interfaces.*.private_ip
  description = "The IPs of the 'inside' interfaces of the ASAv appliances."
}

output "management_ips" {
  value       = aws_network_interface.management_interfaces.*.private_ip
  description = "The IPs of the 'management' interfaces of the ASAv appliances."
}

output "outside_ips" {
  value       = aws_eip.outside_eips.*.public_ip
  description = "The IPs of the 'outside' interfaces of the ASAv appliances."
}
