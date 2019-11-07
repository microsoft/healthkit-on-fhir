<#
.SYNOPSIS
Creates a Config file for the sample application.
.DESCRIPTION
#>
param
(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ConnectionString,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$FhirServerUrl,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ClientId
)

Set-StrictMode -Version Latest

Write-Output $output.PrimaryConnectionString

$json = "{`"eventHubsConnectionString`":`"${ConnectionString}`",`"smartClientBaseUrl`":`"${FhirServerUrl}`",`"smartClientClientId`":`"${ClientId}`"}"
$path = '~\Config.json'

if (Test-Path ~\Config.json) {
    Set-Content $path $json
} else {
    New-Item -Path $path -Value $json
}
