#Define a private DNS zone resource for the backend
resource "azurerm_private_dns_zone" "front" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = azurerm_resource_group.this.name

  tags = var.tags
}

# Define a virtual network link for the private DNS zone and the backend virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "front" {
  name                  = "databricks-vnetlink-front"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.front.name
  virtual_network_id    = azurerm_virtual_network.this.id

  tags = var.tags
}
