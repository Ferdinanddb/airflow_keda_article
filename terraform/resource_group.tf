resource "azurerm_resource_group" "test_keda_airflow_rg" {
  location = var.location
  name     = var.resource_group_name
}