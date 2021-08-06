#Define Deployment Variables
appNamePrefix='tws'
locationDetails=$(cat locationDetails.json)

#Deploy Public IP Address
location=$(echo $locationDetails | jq -c '.[] | select(.Region | match("Primary")) | .Location' -r)
resourceGroupName="${appNamePrefix}-iaas-${location}"

pipName="$appNamePrefix-pip-bastion-$location"

az network public-ip create \
    --name ${pipName} \
    --resource-group ${resourceGroupName} \
    --location ${location} \
    --allocation-method Static \
    --sku Standard

#Deploy Azure Bastion
location=$(echo $locationDetails | jq -c '.[] | select(.Region | match("Primary")) | .Location' -r)
resourceGroupName="${appNamePrefix}-iaas-${location}"

vNet=$(az network vnet list --resource-group ${resourceGroupName})
vNetName=$(echo $vNet | jq '.[0].name' -r)

pip=$(az network public-ip list --resource-group ${resourceGroupName})
pipName=$(echo $pip | jq '.[0].name' -r)

bastionName="${appNamePrefix}-bastion-${location}"

az network bastion create \
    --name ${bastionName} \
    --resource-group ${resourceGroupName} \
    --location ${location} \
    --vnet-name ${vNetName} \
    --public-ip-address ${pipName}

