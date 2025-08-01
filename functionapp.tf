# functionapp.tf
# App Service Plan for the Azure Function (Consumption Plan - Dynamic)

resource "azurerm_app_service_plan" "plan" {
  name                = "costopt-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"  # Consumption plan pricing tier
    size = "Y1"       # Smallest SKU suitable for serverless functions
  }
}

# Azure Function App configured to run PowerShell functions
resource "azurerm_function_app" "function" {
  name                       = "costopt-function-${random_integer.suffix.result}"  # Unique function app name with suffix
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.plan.id                     # Link to the service plan
  storage_account_name       = azurerm_storage_account.storage.name                 # Storage account for function app files
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key

  os_type   = "Windows"  # PowerShell Azure Functions currently require Windows OS
  version   = "~4"       # Use Azure Functions Runtime version 4 (recommended for PS Core)
  https_only = true      # Enforce HTTPS access only

  # Application settings passed as environment variables to your function code
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "powershell"                      # Specifies the function runtime
    CosmosDBAccount          = azurerm_cosmosdb_account.cosmos.name
    CosmosDBKey              = var.cosmosdb_primary_key          # Cosmos DB key passed securely via variable
    CosmosDBDatabase         = azurerm_cosmosdb_sql_database.db.name
    CosmosDBContainer        = azurerm_cosmosdb_sql_container.container.name
    AzureWebJobsStorage      = azurerm_storage_account.storage.primary_connection_string
    BlobContainerName        = azurerm_storage_container.container.name
  }

  tags = {
    environment = "dev"
    project     = "cost-optimization"
  }
}
