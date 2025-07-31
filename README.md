# 💼 Azure Cost Optimization: Archive Billing Data from Cosmos DB to Blob Storage

This project automates the archival of billing data from **Azure Cosmos DB** to **Azure Blob Storage** using an **Azure Function App** scheduled via a timer trigger. All resources are deployed using **Terraform**.

---

## 🛠️ Prerequisites

Before you begin, ensure you have the following:

- [Terraform](https://developer.hashicorp.com/terraform/downloads) installed
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed and logged in
- Active Azure subscription with contributor access

---

## 📌 Features

- Provisioning of Azure resources using Terraform
- PowerShell-based Azure Function to move old billing data
- Daily scheduled trigger (adjustable) using `function.json`
- Archived files saved in Azure Blob Storage
- Helps reduce costs by offloading old data from Cosmos DB

---

## 💡 What This Project Includes

- **Terraform scripts** to create:
  - Resource Group
  - Cosmos DB
  - Storage Account
  - Azure Function App

- **Azure Function** (PowerShell script):
  - Runs on a schedule (every day)
  - Reads old billing records from Cosmos DB
  - Stores them in a Storage container as JSON files

---

## 🧱 Project Structure

📁 azure-cost-optimization-assignment/  
├── main.tf         # Azure provider setup and Resource Group creation  
├── storage.tf      # Azure Storage Account and Blob Container configuration  
├── cosmosdb.tf     # Azure Cosmos DB provisioning for billing records  
├── functionapp.tf  # Azure Function App infrastructure deployment  
├── README.md       # Project documentation and instructions  
└── 📁 archive-function/  
    ├── archive-billing.ps1  # PowerShell script to archive Cosmos DB records to Blob Storage  
    └── function.json       # Timer trigger schedule configuration for the Azure Function  

---

## 🚀 How to Use

### Step 1: Deploy Infrastructure

1. Open your terminal and navigate to the project root directory.  
2. Run `terraform init` to initialize Terraform.  
3. Run `terraform plan` to review planned changes.  
4. Run `terraform apply` to apply changes and create resources.  
5. Confirm with `yes` when prompted.  

### Step 2: Deploy Azure Function Code

1. In Azure Portal, go to your Function App → Functions → select your function → Code + Test tab.  
2. Upload or replace these files:  
   - `archive-billing.ps1`  
   - `function.json`  
3. Navigate to the Configuration tab in your Function App.  
4. Add a new Application Setting:  
   - **Key:** `CosmosDBConnection`  
   - **Value:** Your Cosmos DB connection string (from Azure Portal)  
     > *Find Cosmos DB connection string under Azure Portal → Your Cosmos DB → Keys*

> **Security Tip:** Do **not** hardcode connection strings inside your PowerShell script.

### Step 3: Monitor & Schedule

1. The Azure Function runs automatically every 24 hours, controlled by `function.json`.  
2. Modify the schedule by editing the CRON expression in `function.json`.  
3. Monitor function executions and logs in Azure Portal under Monitoring or Application Insights.  

### Step 4: Verify Archival

1. Check that billing records older than 3 months have been archived to Blob Storage.  
2. Confirm these records are deleted from Cosmos DB.  
3. Review Function App logs for errors or warnings.  

---

## Cleanup

- To avoid ongoing charges, destroy all created Azure resources using:

```bash
terraform destroy
```

* Confirm the deletion by typing "yes" when prompted. This will clean up all resources provisioned by Terraform.

---

## 🔒 Security Considerations

* Store sensitive information such as connection strings in Azure Function App Application Settings rather than hardcoding them in scripts.

* For production environments, use Azure Managed Identities combined with Azure Key Vault to securely manage secrets.

* Never commit secrets or credentials to your GitHub repository, especially public ones.

* Regularly review and rotate access keys to minimize risk.

---

## 📦 Output

* This project ensures that billing records older than 3 months are safely archived as JSON files in Azure Blob Storage.

* Cosmos DB storage size and related costs are significantly reduced, without impacting data availability or API contracts.

---

## 👩‍💼 Author

Sai Suneetha
Azure DevOps Engineer
[LinkedIn](https://www.linkedin.com/in/sunneetha/)

---

## 📄 License

* This project is provided “as-is” for demonstration purposes.
* Please review and enhance security before deploying to production environments.