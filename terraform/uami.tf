resource "azurerm_user_assigned_identity" "test_keda_airflow_uami_airflow_keda" {
  location            = var.location
  name                = "test_keda_airflow_uami_airflow_keda"
  resource_group_name = azurerm_resource_group.test_keda_airflow_rg.name
}

output "test_keda_airflow_uami_airflow_keda_object_id" {
  value     = azurerm_user_assigned_identity.test_keda_airflow_uami_airflow_keda.principal_id
  sensitive = false
}

output "test_keda_airflow_uami_airflow_keda_client_id" {
  value     = azurerm_user_assigned_identity.test_keda_airflow_uami_airflow_keda.client_id
  sensitive = false
}


resource "azurerm_user_assigned_identity" "test_keda_airflow_uami_aks_kubelet" {
  location            = var.location
  name                = "test_keda_airflow_uami_aks_kubelet"
  resource_group_name = azurerm_resource_group.test_keda_airflow_rg.name
}

resource "azurerm_role_assignment" "aks_cp_MI_operator_binding" {
  scope                = azurerm_resource_group.test_keda_airflow_rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.test_keda_airflow_uami_aks_kubelet.principal_id
}

# To be able to create PV and PVC in k8s
resource "azurerm_role_assignment" "aks_cp_sa_contributor_binding" {
  scope                = azurerm_resource_group.test_keda_airflow_rg.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_user_assigned_identity.test_keda_airflow_uami_aks_kubelet.principal_id
}
