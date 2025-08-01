# cosmosdb.tf
# Create Azure Cosmos DB account, database and container for recent billing records

# Cosmos DB Account
resource "azurerm_cosmosdb_account" "cosmos" {
  name                = "costoptcosmosdb${random_integer.suffix.result}" # Unique name with suffix
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"  # Cosmos DB API for Core (SQL)

  consistency_policy {
    consistency_level = "Session"  # Balanced performance and consistency
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }
}

# Cosmos DB SQL Database for billing records
resource "azurerm_cosmosdb_sql_database" "db" {
  name                = "billingdb"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
}

# Cosmos DB SQL Container to store billing records
resource "azurerm_cosmosdb_sql_container" "container" {
  name                = "billingrecords"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  database_name       = azurerm_cosmosdb_sql_database.db.name
  partition_key_path  = "/partitionKey"  # Partition key for scaling
  throughput          = 400              # Provisioned throughput (RU/s)
}
