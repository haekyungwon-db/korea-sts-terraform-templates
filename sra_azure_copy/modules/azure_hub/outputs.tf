output "client_config" {
  value = data.azurerm_client_config.current
}

output "firewall_name" {
  value = azurerm_firewall.this.name
}

output "ipgroup_id" {
  value = azurerm_ip_group.this.id
}

output "route_table_id" {
  value = azurerm_route_table.this.id
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "private_link_info" {
  value = {
    dns_zone_id = azurerm_private_dns_zone.auth_front.id
    subnet_id   = azurerm_subnet.privatelink.id
  }
}

output "tenant_id" {
  value = local.tenant_id
}
