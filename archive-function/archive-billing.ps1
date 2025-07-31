# run.ps1 - Azure Function Timer Trigger Script
# Archives Cosmos DB billing records older than 3 months to Blob Storage
# Deletes archived records from Cosmos DB to reduce costs

param($Timer)

# Import Az modules (make sure your Function App has Az modules installed)
Import-Module Az.CosmosDB
Import-Module Az.Storage

# === Replace the below placeholders with your actual Azure resource details ===

$cosmosAccount = "<COSMOS_DB_ACCOUNT_NAME>"        # e.g., "mycosmosdbaccount" from azurerm_cosmosdb_account resource
$cosmosKey = "<COSMOS_DB_KEY>"                      # Primary key from Azure portal or Terraform output
$databaseName = "billingdb"                          # From azurerm_cosmosdb_sql_database resource
$containerName = "billingrecords"                    # From azurerm_cosmosdb_sql_container resource

$storageConnectionString = "<STORAGE_ACCOUNT_CONNECTION_STRING>"  # From Azure portal or Terraform output
$blobContainerName = "archive"                        # From azurerm_storage_container resource

# Create Cosmos DB client context
$cosmosContext = New-CosmosDbContext -AccountName $cosmosAccount -AccountKey $cosmosKey

# Calculate cutoff date - 3 months ago in UTC
$threeMonthsAgo = (Get-Date).AddMonths(-3).ToUniversalTime()

# Query Cosmos DB for records older than cutoff date
$query = "SELECT * FROM c WHERE c.timestamp < '$($threeMonthsAgo.ToString("o"))'"

Write-Output "Starting archival process at $(Get-Date)"

try {
    $oldRecords = Get-CosmosDbDocument -Context $cosmosContext -Database $databaseName -Collection $containerName -Query $query

    # Create Blob Storage context
    $blobContext = New-AzStorageContext -ConnectionString $storageConnectionString

    foreach ($record in $oldRecords) {
        $recordId = $record.id
        $partitionKey = $record.partitionKey  # Adjust if your partition key is named differently
        $blobName = "$recordId.json"
        $recordJson = $record | ConvertTo-Json -Depth 10

        # Upload to Blob Storage
        Write-Output "Uploading record $recordId to Blob Storage..."
        Set-AzStorageBlobContent -Context $blobContext -Container $blobContainerName -Content $recordJson -Blob $blobName

        # Delete from Cosmos DB
        Write-Output "Deleting record $recordId from Cosmos DB..."
        Remove-CosmosDbDocument -Context $cosmosContext -Database $databaseName -Collection $containerName -Id $recordId -PartitionKey $partitionKey

        Write-Output "Archived and deleted record $recordId successfully."
    }
}
catch {
    Write-Error "Error during archival process: $_"
}

Write-Output "Archival process completed at $(Get-Date)"
