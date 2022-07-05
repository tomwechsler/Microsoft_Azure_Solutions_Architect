#Define Deployment Variables
appNamePrefix='tws'
locationDetails=$(cat ./locationDetails.json)

#Deploy VM Scale Set Load Balancer
#Define Deployment Variables
location=$(echo $locationDetails | jq -c '.[] | select(.Region | match("Secondary")) | .Location' -r)
resourceGroupName="${appNamePrefix}-iaas-${location}"

vNetName="$appNamePrefix-vnet-$location"
subnetName='AppSubnet'
lbName="$appNamePrefix-app-lb-$location"

#Deploy internal Load Balancer
az network lb create \
    --name ${lbName} \
    --resource-group ${resourceGroupName} \
    --location ${location} \
    --sku Basic \
    --vnet-name ${vNetName} \
    --subnet ${subnetName} \
    --frontend-ip-name PrivateFrontEnd \
    --backend-pool-name AppVmScaleSet

#Provision Health Probe
healthProbeName='tws-app-probe-tcp-80'

az network lb probe create \
    --resource-group ${resourceGroupName} \
    --lb-name ${lbName} \
    --name ${healthProbeName} \
    --protocol tcp \
    --port 80

#Provision load balancer Rule
ruleName='tws-app-lb-tcp-80'

az network lb rule create \
    --resource-group ${resourceGroupName} \
    --lb-name ${lbName} \
    --name ${ruleName} \
    --protocol tcp \
    --frontend-port 80 \
    --backend-port 80 \
    --frontend-ip-name PrivateFrontEnd \
    --backend-pool-name AppVmScaleSet \
    --probe-name ${healthProbeName} \
    --idle-timeout 15

#Deploy Virtual Machine Scale Set
location=$(echo $locationDetails | jq -c '.[] | select(.Region | match("Secondary")) | .Location' -r)
resourceGroupName="${appNamePrefix}-iaas-${location}"
vmssName="$appNamePrefix-app-vmss-$location"

vNetName="$appNamePrefix-vnet-$location"
subnetName='AppSubnet'

lb=$(az network lb list --resource-group ${resourceGroupName})
lbName=$(echo $lb | jq '.[0].name' -r)

vmImage='UbuntuLTS'
vmSize='Standard_DS1_v2'
adminUser='twsadmin'
adminPassword='P@ssw0rd220475'

az vmss create \
    --name ${vmssName} \
    --resource-group ${resourceGroupName} \
    --location ${location} \
    --image ${vmImage} \
    --instance-count 2 \
    --vm-sku ${vmSize} \
    --authentication-type password \
    --admin-username ${adminUser} \
    --admin-password ${adminPassword} \
    --vnet-name ${vNetName} \
    --subnet ${subnetName} \
    --load-balancer ${lbName}

