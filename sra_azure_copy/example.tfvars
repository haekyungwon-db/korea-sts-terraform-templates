databricks_account_id = "[databricks account id value]"
location = "koreacentral"
hub_vnet_cidr = "10.178.0.0/20"
hub_resource_group_name = "[hub resource group name]"
hub_vnet_name = "[hub vnet group name]"
spoke_config = [{prefix="[prefix value]", cidr="10.179.0.0/20", tags={}}]
test_vm_password = "[password should have Uppercase, Lowercase, alphabet, number, and symbol]"
client_secret = "[client secret value of Databricks service principal having account admin role]"
