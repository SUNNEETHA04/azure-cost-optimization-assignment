# storage.tf
# Create Azure Storage Account and Blob Container for archiving old billing records

resource "azurerm_storage_account" "storage" {
  name                     = "costoptstorage${random_integer.suffix.result}"  # Unique storage account name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"      # Standard performance tier
  account_replication_type = "LRS"           # Locally redundant storage
}

# Blob container to store archived billing records
resource "azurerm_storage_container" "container" {
  name                  = "archivedbilling"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"           # Private access for security
}
