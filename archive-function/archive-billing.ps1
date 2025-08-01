# archive-billing.ps1 - Azure Function Timer Trigger Script
# Archives Cosmos DB billing records older than 3 months to Blob Storage
# Deletes archived records from Cosmos DB to reduce costs

param($Timer)  # This parameter is required for Timer Trigger function

# Read secrets and connection info from Azure Function App environment variables
$cosmosAccount = $env:CosmosDBAccount
$cosmosKey = $env:CosmosDBKey
$databaseName = $env:CosmosDBDatabase
$containerName = $env:CosmosDBContainer
$storageConnectionString = $env:AzureWebJobsStorage
$blobContainerName = $env:BlobContainerName

# Import necessary Azure modules for Cosmos DB and Storage
Import-Module Az.CosmosDB
Import-Module Az.Storage

Write-Output "Starting archival process at $(Get-Date)"

# Initialize Cosmos DB context (replace with SDK/REST if cmdlets unavailable)
$cosmosContext = New-CosmosDbContext -AccountName $cosmosAccount -AccountKey $cosmosKey

# Calculate the cutoff date: records older than 3 months will be archived
$threeMonthsAgo = (Get-Date).AddMonths(-3).ToUniversalTime().ToString("o")

# Cosmos DB SQL query to find records older than cutoff
$query = "SELECT * FROM c WHERE c.timestamp < '$threeMonthsAgo'"

# Create Azure Storage context for Blob operations
$blobContext = New-AzStorageContext -ConnectionString $storageConnectionString

try {
    # Get old records from Cosmos DB matching query
    $oldRecords = Get-CosmosDbDocument -Context $cosmosContext -Database $databaseName -Collection $containerName -Query $query

    foreach ($record in $oldRecords) {
        $maxRetries = 3
        $retryCount = 0
        $success = $false

        # Retry logic per record, in case of transient errors
        while (-not $success -and $retryCount -lt $maxRetries) {
            try {
                $recordId = $record.id
                $partitionKey = $record.partitionKey
                $blobName = "${recordId}.json"

                # Convert the record to JSON with sufficient depth
                $recordJson = $record | ConvertTo-Json -Depth 10

                # Save JSON to a temporary file for uploading
                $tempFile = [System.IO.Path]::GetTempFileName()
                $recordJson | Out-File -FilePath $tempFile -Encoding utf8

                Write-Output "Uploading record ${recordId} to Blob Storage (Attempt $($retryCount + 1))..."
                Set-AzStorageBlobContent -File $tempFile -Container $blobContainerName -Blob $blobName -Force -Context $blobContext

                # Clean up temporary file after successful upload
                Remove-Item $tempFile

                Write-Output "Deleting record ${recordId} from Cosmos DB..."
                Remove-CosmosDbDocument -Context $cosmosContext -Database $databaseName -Collection $containerName -Id $recordId -PartitionKey $partitionKey

                Write-Output "Archived and deleted record ${recordId} successfully."
                $success = $true
            }
            catch {
                Write-Error "Error archiving record ${recordId}: $_"
                $retryCount++
                Start-Sleep -Seconds (5 * $retryCount)  # Exponential backoff before retry
            }
        }

        if (-not $success) {
            Write-Error "Failed to archive record ${recordId} after $maxRetries attempts."
            # Optional: log to storage or alert system here
        }
    }
}
catch {
    Write-Error "Error during archival process: $_"
}

Write-Output "Archival process completed at $(Get-Date)"
# End of script
