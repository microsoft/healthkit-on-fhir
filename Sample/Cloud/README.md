# HealthKitOnFhir Sample App Cloud Deployment

This directory contains tools to deploy and configure the cloud services that support the HealthKitOnFhir sample application. The [Create-IomtFhirCloudEnvironment.ps1](Scripts/Create-IomtFhirCloudEnvironment.ps1) script will deploy an [IoMT FHIR Connector for Azure](https://github.com/microsoft/iomt-fhir) and a FHIR server ([Azure API for FHIR](https://docs.microsoft.com/azure/healthcare-apis)) to your Azure account.



# Prerequisites

**If you are running the PowerShell script in the Azure Cloud Shell, Installing the Az and AzureAd modules are not required.**

**Windows:** Install the `Az` and `AzureAd` powershell modules:

```PowerShell
Install-Module Az
Install-Module AzureAd
```

**Mac:** Install the `Az` and `AzureAD.Standard.Preview` powershell modules:

```PowerShell
Install-Module Az
Install-Module AzureAD.Standard.Preview -RequiredVersion 0.0.0.10
```

**Note:** The `AzureAD.Standard.Preview` powershell module is pre-release software go [here](https://www.poshtestgallery.com/packages/AzureAD.Standard.Preview/0.0.0.10) for more information.

# Deployment

To deploy the sample scenario, first clone this git repo and find the deployment scripts folder:

```PowerShell
git clone https://github.com/Microsoft/healthkit-on-fhir
cd healthkit-on-fhir/Sample/Cloud/Scripts
```

Log into your Azure subscription:

```PowerShell
Login-AzAccount
```

Connect to Azure AD with:

```PowerShell
Connect-AzureAd -TenantDomain <AAD TenantDomain>
```

**NOTE** The connection to Azure AD can be made using a different tenant domain than the one tied to your Azure subscription. If you don't have privileges to create app registrations, users, etc. in your Azure AD tenant, you can [create a new one](https://docs.microsoft.com/azure/active-directory/develop/quickstart-create-new-tenant), which will just be used for demo identities, etc.

Then deploy using the PowerShell Script:

```PowerShell
.\Create-IomtFhirCloudEnvironment.ps1 -EnvironmentName <ENVIRONMENTNAME> -AdminPassword $(ConvertTo-SecureString "<ADMINPASSWORD>" -AsPlainText -Force)
```

The [Create-IomtFhirCloudEnvironment.ps1](Scripts/Create-IomtFhirCloudEnvironment.ps1) script will deploy all of the cloud services required for the sample application. The script will generate a Config.json file and save it to the Home directory. The Config.json file is used to configure the sample application to use the newly deployed cloud services. The script will also output an "Admin" user and password that can be used to login to the application.
