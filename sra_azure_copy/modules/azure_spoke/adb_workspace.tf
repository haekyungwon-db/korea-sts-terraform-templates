# Define an Azure Databricks workspace resource
resource "azurerm_databricks_workspace" "this" {
  name                                                = "${var.prefix}-adb-workspace"
  resource_group_name                                 = azurerm_resource_group.this.name
  location                                            = var.location
  sku                                                 = "premium"
  customer_managed_key_enabled                        = false
  infrastructure_encryption_enabled                   = false
  public_network_access_enabled                       = true
  network_security_group_rules_required               = "AllRules"

  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = azurerm_virtual_network.this.id
    public_subnet_name                                   = azurerm_subnet.host.name
    private_subnet_name                                  = azurerm_subnet.container.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.host.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.container.id
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}