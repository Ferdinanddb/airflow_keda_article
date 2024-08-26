
resource "azurerm_postgresql_flexible_server" "airflow_pg_server" {
  name                = "test-keda-airflow-pg5"
  resource_group_name = azurerm_resource_group.test_keda_airflow_rg.name
  location            = var.location
  version             = "14"
  zone                = "2"

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = false
    tenant_id                     = var.tenant_id
  }

  storage_mb   = 32768
  storage_tier = "P10"

  sku_name = "GP_Standard_D2s_v3"
}


data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "pg_fw_authorize_my_ip" {
  name             = "pg_fw_authorize_my_ip"
  server_id        = azurerm_postgresql_flexible_server.airflow_pg_server.id
  start_ip_address = chomp(data.http.myip.response_body)
  end_ip_address   = chomp(data.http.myip.response_body)
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "postgres_flex_server_fwr_allow_azure" {
  name             = "AllowAllAzure"
  server_id        = azurerm_postgresql_flexible_server.airflow_pg_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}


resource "azurerm_postgresql_flexible_server_active_directory_administrator" "terraform_aad_admin" {
  server_name         = azurerm_postgresql_flexible_server.airflow_pg_server.name
  resource_group_name = azurerm_resource_group.test_keda_airflow_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azuread_service_principal.example.object_id
  principal_name      = data.azuread_service_principal.example.display_name
  principal_type      = "ServicePrincipal"
}

resource "azurerm_postgresql_flexible_server_database" "airflow_pg_database" {
  name       = "airflow_db"
  server_id  = azurerm_postgresql_flexible_server.airflow_pg_server.id
  collation  = "en_US.utf8"
  charset    = "UTF8"
  depends_on = [azurerm_postgresql_flexible_server_active_directory_administrator.terraform_aad_admin]
}