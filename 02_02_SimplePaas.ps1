Set-Location c:\
Clear-Host

#Install Az Module
Install-Module -Name Az -AllowClobber -Force -Verbose

#Import Az Module and Authenticate to Azure
Import-Module -Name Az

#Log into Azure
Connect-AzAccount

#Select the correct subscription
Get-AzSubscription -SubscriptionName "MSDN Platforms" | Select-AzSubscription
Get-AzContext

#Define Deployment Variables
$appNamePrefix = 'tws'
$resourceGroupName = "$appNamePrefix-simple-paas"
$resourceGroupLocation = 'westeurope'

$resourceProviderNamespace = 'Microsoft.Web'
$resourceTypeName = 'sites'

$randomString = ([char[]]([char]'a'..[char]'z') + 0..9 | Sort-Object {Get-Random})[0..8] -join ''
$appServicePlanName = $appNamePrefix + $randomString
$webAppName = $appNamePrefix + $randomString

#Get ARM Provider Locations
((Get-AzResourceProvider `
    -ProviderNamespace "$resourceProviderNamespace").ResourceTypes | `
    Where-Object {$_.ResourceTypeName -eq "$resourceTypeName"}).Locations | `
    Sort-Object

#Create ARM Resource Group
New-AzResourceGroup `
    -Name $resourceGroupName `
    -Location $resourceGroupLocation `
    -Verbose -Force

#Create App Service Plan
$appServicePlan = New-AzAppServicePlan `
    -ResourceGroupName $resourceGroupName `
    -Location $resourceGroupLocation `
    -Name $appServicePlanName `
    -Tier Standard `
    -WorkerSize Small `
    -Verbose

#Create Web App
New-AzWebApp `
    -ResourceGroupName $resourceGroupName `
    -Location $resourceGroupLocation `
    -AppServicePlan $appServicePlan.ServerFarmWithRichSkuName `
    -Name $webAppName `
    -Verbose
