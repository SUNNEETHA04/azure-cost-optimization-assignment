# main.tf
# Configure the Azure Provider and create a Resource Group

provider "azurerm" {
  features {}
}

# Create a Resource Group to contain all resources
resource "azurerm_resource_group" "rg" {
  name     = "rg-cost-optimization"
  location = "East US"
}
