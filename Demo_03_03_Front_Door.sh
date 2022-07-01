#Define Deployment Variables
appNamePrefix='tws'
locations=(
    "westeurope"
    "northeurope"
)

resourceGroupName="${appNamePrefix}-paas-westeurope"
resourceGroup=$(az group show --name ${resourceGroupName})
resourceGroupId=$(echo $resourceGroup | jq .id -r | shasum)
nameSuffix="${resourceGroupId:0:4}"

#Create Azure Front Door
frontDoorName=${appNamePrefix}-paas-frontend-${nameSuffix}
webApp1Uri=$(az webapp list --resource-group tws-paas-westeurope | jq '.[0].name' -r).azurewebsites.net
webApp2Uri=$(az webapp list --resource-group tws-paas-northeurope | jq '.[0].name' -r).azurewebsites.net

az network front-door create \
    --resource-group $resourceGroupName \
    --name ${frontDoorName} \
    --accepted-protocols Https \
    --backend-address $webApp1Uri \
    --forwarding-protocol HttpsOnly

az network front-door backend-pool backend add \
    --resource-group ${resourceGroupName} \
    --front-door-name ${frontDoorName} \
    --pool-name DefaultBackendPool \
    --address $webApp2Uri \
    --backend-host-header $webApp2Uri

#Create HTTP to HTTPS Redirect Rule
az network front-door routing-rule create \
    --resource-group ${resourceGroupName} \
    --front-door-name ${frontDoorName} \
    --name HttpToHttpsRedirect \
    --frontend-endpoints DefaultFrontendEndpoint \
    --accepted-protocols Http \
    --route-type Redirect \
    --redirect-protocol HttpsOnly \
    --redirect-type Found

#Restrict access to Web Apps
for i in "${locations[@]}"; do
    # Define Deployment Variables
    resourceGroupName="${appNamePrefix}-paas-${i}"
    resourceGroup=$(az group show --name ${resourceGroupName} --output json)
    resourceGroupLocation=$(echo $resourceGroup | jq .location -r)
    resourceGroupId=$(echo $resourceGroup | jq .id -r | shasum)
    nameSuffix="${resourceGroupId:0:4}"

    webAppName="${appNamePrefix}-web-${resourceGroupLocation}-${nameSuffix}"

    az webapp config access-restriction add \
        --resource-group $resourceGroupName \
        --name $webAppName \
        --priority 100 \
        --service-tag AzureFrontDoor.Backend
done
