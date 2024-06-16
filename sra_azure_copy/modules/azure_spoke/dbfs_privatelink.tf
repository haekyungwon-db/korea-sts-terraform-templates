# # Define a private DNS zone for the dbfs_dfs resource
# resource "azurerm_private_dns_zone" "dbfs_dfs" {
#   name                = "privatelink.dfs.core.windows.net"
#   resource_group_name = azurerm_resource_group.this.name

#   tags = var.tags
# }

# # Define a private endpoint for the dbfs_dfs resource
# resource "azurerm_private_endpoint" "dbfs_dfs" {
#   name                = "dbfspe-dfs"
#   location            = azurerm_resource_group.this.location
#   resource_group_name = azurerm_resource_group.this.name
#   subnet_id           = azurerm_subnet.privatelink.id

#   # Define the private service connection for the dbfs_dfs resource
#   private_service_connection {
#     name                           = "ple-${var.prefix}-dbfs-dfs"
#     private_connection_resource_id = join("", [azurerm_databricks_workspace.this.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/", local.dbfs_name])
#     is_manual_connection           = false
#     subresource_names              = ["dfs"]
#   }

#   # Associate the private DNS zone with the private endpoint
#   private_dns_zone_group {
#     name                 = "private-dns-zone-dbfs"
#     private_dns_zone_ids = [azurerm_private_dns_zone.dbfs_dfs.id]
#   }

#   tags = var.tags
# }

# # Define a virtual network link for the dbfs_dfs private DNS zone
# resource "azurerm_private_dns_zone_virtual_network_link" "dbfs_dfs" {
#   name                  = "dbfs-dfs"
#   resource_group_name   = azurerm_resource_group.this.name
#   private_dns_zone_name = azurerm_private_dns_zone.dbfs_dfs.name
#   virtual_network_id    = azurerm_virtual_network.this.id

#   tags = var.tags
# }

# # Define a private endpoint for the dbfs_blob resource
# resource "azurerm_private_endpoint" "dbfspe_blob" {
#   name                = "dbfs-blob"
#   location            = azurerm_resource_group.this.location
#   resource_group_name = azurerm_resource_group.this.name
#   subnet_id           = azurerm_subnet.privatelink.id

#   # Define the private service connection for the dbfs_blob resource
#   private_service_connection {
#     name                           = "ple-${var.prefix}-dbfs-blob"
#     private_connection_resource_id = join("", [azurerm_databricks_workspace.this.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/", local.dbfs_name])
#     is_manual_connection           = false
#     subresource_names              = ["blob"]
#   }

#   # Associate the private DNS zone with the private endpoint
#   private_dns_zone_group {
#     name                 = "private-dns-zone-dbfs"
#     private_dns_zone_ids = [azurerm_private_dns_zone.dbfs_blob.id]
#   }

#   tags = var.tags
# }

# # Define a private DNS zone for the dbfs_blob resource
# resource "azurerm_private_dns_zone" "dbfs_blob" {
#   name                = "privatelink.blob.core.windows.net"
#   resource_group_name = azurerm_resource_group.this.name

#   tags = var.tags
# }

# # Define a virtual network link for the dbfs_blob private DNS zone
# resource "azurerm_private_dns_zone_virtual_network_link" "dbfs_blob" {
#   name                  = "dbfs-blob"
#   resource_group_name   = azurerm_resource_group.this.name
#   private_dns_zone_name = azurerm_private_dns_zone.dbfs_blob.name
#   virtual_network_id    = azurerm_virtual_network.this.id

#   tags = var.tags
# }
