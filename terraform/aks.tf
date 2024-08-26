resource "azurerm_kubernetes_cluster" "test_keda_airflow_aks" {
  name                = "test-keda-airflow-aks"
  location            = var.location
  resource_group_name = azurerm_resource_group.test_keda_airflow_rg.name
  dns_prefix          = "testkedaairflowaks"

  private_cluster_enabled   = false
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.test_keda_airflow_uami_aks_kubelet.client_id
    object_id                 = azurerm_user_assigned_identity.test_keda_airflow_uami_aks_kubelet.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.test_keda_airflow_uami_aks_kubelet.id
  }

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_D2_v2"

    upgrade_settings {
      max_surge = "10%"
    }
  }

  network_profile {
    network_plugin = "kubenet"
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test_keda_airflow_uami_aks_kubelet.id
    ]
  }

  depends_on = [
    azurerm_role_assignment.aks_cp_MI_operator_binding,
  ]
}


resource "azurerm_federated_identity_credential" "federated_ids_airflow" {
  for_each            = toset(["airflow-migrate-database-job", "airflow-scheduler", "airflow-webserver", "airflow-worker", "default", "airflow-redis", "airflow-flower", "airflow-create-user-job", "airflow-triggerer"])
  name                = each.key
  resource_group_name = azurerm_resource_group.test_keda_airflow_rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.test_keda_airflow_aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.test_keda_airflow_uami_airflow_keda.id
  subject             = "system:serviceaccount:airflow:${each.key}"
}

resource "azurerm_federated_identity_credential" "federated_ids_keda" {
  for_each            = toset(["keda-metrics-server", "keda-operator", "keda-webhook"])
  name                = each.key
  resource_group_name = azurerm_resource_group.test_keda_airflow_rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.test_keda_airflow_aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.test_keda_airflow_uami_airflow_keda.id
  subject             = "system:serviceaccount:keda:${each.key}"
}