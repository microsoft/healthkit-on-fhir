<#
.SYNOPSIS
Creates a new FHIR Server Samples environment.
.DESCRIPTION
#>
param
(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(5,12)]
    [ValidateScript({
        if ("$_" -Like "* *") {
            throw "Environment name cannot contain whitespace"
            return $false
        }
        else {
            return $true
        }
    })]
    [string]$EnvironmentName,

    [Parameter(Mandatory = $false)]
    [ValidateSet('West US', 'South Central US')]
    [string]$EnvironmentLocation = "West US",

    [Parameter(Mandatory = $false)]
    [ValidateSet('North Europe', 'Central US')]
    [string]$IotCentralLocation = "Central US",

    [Parameter(Mandatory = $false)]
    [string]$FhirApiLocation = "northcentralus",

    [Parameter(Mandatory = $false)]
    [string]$SourceRepository = "https://t:@dev.azure.com/microsofthealth/Health/_git/health-iomt",
    #"https://github.com/Microsoft/fhir-iomt",

    [Parameter(Mandatory = $false)]
    [string]$SourceRevision = "master"
)

Set-StrictMode -Version Latest

# Get current AzureAd context
try {
    $tenantInfo = Get-AzureADCurrentSessionInfo -ErrorAction Stop
} 
catch {
    throw "Please log in to Azure AD with Connect-AzureAD cmdlet before proceeding"
}

# Get current Az context
try {
    $azContext = Get-AzContext
} 
catch {
    throw "Please log in to Azure RM with Login-AzAccount cmdlet before proceeding"
}

if ($azContext.Account.Type -eq "User") {
    Write-Host "Current context is user: $($azContext.Account.Id)"
    
    $currentUser = Get-AzADUser -UserPrincipalName $azContext.Account.Id

    #If this is guest account, we will try a search instead
    if (!$currentUser) {
        # External user accounts have UserPrincipalNames of the form:
        # myuser_outlook.com#EXT#@mytenant.onmicrosoft.com for a user with username myuser@outlook.com
        $tmpUserName = $azContext.Account.Id.Replace("@", "_")
        $currentUser = Get-AzureADUser -Filter "startswith(UserPrincipalName, '${tmpUserName}')"
        $currentObjectId = $currentUser.ObjectId
    } else {
        $currentObjectId = $currentUser.Id
    }

    if (!$currentObjectId) {
        throw "Failed to find objectId for signed in user"
    }
}
elseif ($azContext.Account.Type -eq "ServicePrincipal") {
    Write-Host "Current context is service principal: $($azContext.Account.Id)"
    $currentObjectId = (Get-AzADServicePrincipal -ServicePrincipalName $azContext.Account.Id).Id
}
else {
    Write-Host "Current context is account of type '$($azContext.Account.Type)' with id of '$($azContext.Account.Id)"
    throw "Running as an unsupported account type. Please use either a 'User' or 'Service Principal' to run this command"
}


# Set up Auth Configuration and Resource Group
./Create-IomtFhirSandboxAuthConfig.ps1 -EnvironmentName $EnvironmentName -EnvironmentLocation $EnvironmentLocation

# $githubRawBaseUrl = $SourceRepository.Replace("github.com","raw.githubusercontent.com").TrimEnd('/')
# $sandboxTemplate = "${githubRawBaseUrl}/${SourceRevision}/deploy/template/default-azuredeploy-sandbox.json"
$sandboxTemplate = "..\template\default-azuredeploy-sandbox.json"

$tenantDomain = $tenantInfo.TenantDomain
$aadAuthority = "https://login.microsoftonline.com/${tenantDomain}"

$iomtUrl = "https://${EnvironmentName}iomt.azurewebsites.net"

$fhirServerUrl = "https://${EnvironmentName}.azurehealthcareapis.com"

$serviceClientId = (Get-AzKeyVaultSecret -VaultName "${EnvironmentName}-ts" -Name "${EnvironmentName}-service-client-id").SecretValueText
$serviceClientSecret = (Get-AzKeyVaultSecret -VaultName "${EnvironmentName}-ts" -Name "${EnvironmentName}-service-client-secret").SecretValueText
$serviceClientObjectId = (Get-AzureADServicePrincipal -Filter "AppId eq '$serviceClientId'").ObjectId
# $dashboardUserUpn  = (Get-AzKeyVaultSecret -VaultName "${EnvironmentName}-ts" -Name "${EnvironmentName}-admin-upn").SecretValueText
# $dashboardUserOid = (Get-AzureADUser -Filter "UserPrincipalName eq '$dashboardUserUpn'").ObjectId

$accessPolicies = @()
$accessPolicies += @{ "objectId" = $currentObjectId.ToString() }
$accessPolicies += @{ "objectId" = $serviceClientObjectId.ToString() }
# $accessPolicies += @{ "objectId" = $dashboardUserOid.ToString() }

# Deploy the template
New-AzResourceGroupDeployment -TemplateFile $sandboxTemplate -ResourceGroupName $EnvironmentName -ServiceName $EnvironmentName -FhirServiceLocation $FhirApiLocation -FhirServiceAuthority $aadAuthority -FhirServiceResource $fhirServerUrl -FhirServiceClientId $serviceClientId -FhirServiceClientSecret $serviceClientSecret -FhirServiceAccessPolicies $accessPolicies -RepositoryUrl $SourceRepository -RepositoryBranch $SourceRevision -FhirServiceUrl $fhirServerUrl -AppServiceLocation $EnvironmentLocation 

Write-Host "Warming up site..."
Invoke-WebRequest -Uri "${fhirServerUrl}/metadata" | Out-Null
Invoke-WebRequest -Uri $iomtUrl | Out-Null 

@{
    iomtUrl                   = $iomtUrl
    fhirServerUrl             = $fhirServerUrl
}