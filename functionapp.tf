# functionapp.tf
# Create an Azure Function App for running the archival process

resource "azurerm_app_service_plan" "plan" {
  name                = "costopt-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "FunctionApp"
  sku {
    tier = "Dynamic"  # Serverless consumption plan
    size = "Y1"
  }
}

resource "azurerm_function_app" "function" {
  name                       = "costopt-function-${random_integer.suffix.result}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  version                    = "~3"
  os_type                    = "linux"
  runtime_stack              = "node"          # Node.js runtime for Azure Function
  https_only                = true
  site_config {
    application_stack {
      node_version = "~14"
    }
  }
}
