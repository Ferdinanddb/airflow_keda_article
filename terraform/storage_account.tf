resource "azurerm_storage_account" "airflow_sa" {
  name                          = "testkedaairflowsa"
  resource_group_name           = azurerm_resource_group.test_keda_airflow_rg.name
  location                      = var.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  nfsv3_enabled                 = false
  public_network_access_enabled = true
}


resource "azurerm_storage_share" "airflow_logs_fileshare" {
  name                 = "airflow-logs"
  storage_account_name = azurerm_storage_account.airflow_sa.name
  quota                = 10
}