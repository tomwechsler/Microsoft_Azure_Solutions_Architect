#Check the subscription
az account show

#List all subscription's
az account list --all --output table

#Set the right subscription
az account set --subscription "Microsoft Azure Sponsorship"

#Define Deployment Variables
appNamePrefix='tws'
locations=(
    "westeurope"
    "northeurope"
)

#Create ARM Resource Groups
for i in "${locations[@]}"; do
    resourceGroupName="${appNamePrefix}-paas-${i}"
    az group create --name ${resourceGroupName} --location ${i} \
    --output table
done

#Create App Service Plans
for i in "${locations[@]}"; do
    #Define Deployment Variables
    resourceGroupName="${appNamePrefix}-paas-${i}"
    resourceGroup=$(az group show --name ${resourceGroupName} --output json)
    resourceGroupLocation=$(echo $resourceGroup | jq .location -r)

    appServicePlanName="${appNamePrefix}-plan-${resourceGroupLocation}"

    #Deploy App Service Plans
    az appservice plan create \
        --resource-group $(echo $resourceGroup | jq .name -r) \
        --name ${appServicePlanName} \
        --location $(echo $resourceGroup | jq .location -r) \
        --sku S1 \
        --output none
done

#Create Web Apps
for i in "${locations[@]}"; do
    #Define Deployment Variables
    resourceGroupName="${appNamePrefix}-paas-${i}"
    resourceGroup=$(az group show --name ${resourceGroupName} --output json)
    resourceGroupLocation=$(echo $resourceGroup | jq .location -r)
    resourceGroupId=$(echo $resourceGroup | jq .id -r | shasum)
    nameSuffix="${resourceGroupId:0:4}" 

    webAppName="${appNamePrefix}-web-${resourceGroupLocation}-${nameSuffix}"
    appServicePlanName="${appNamePrefix}-plan-${resourceGroupLocation}"
    
    #Deploy Web Apps
    az webapp create \
        --resource-group $(echo $resourceGroup | jq .name -r) \
        --name ${webAppName} \
        --plan ${appServicePlanName}
done
