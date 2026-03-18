echo "Create NSGs for each tier to allow only necessary communications" ...

#  az network nsg create \
#   --name nsgweb \
#   --resource-group multitierRG

#  az network nsg create \
#   --name nsgapp \
#   --resource-group multitierRG

#  az network nsg create \
#   --name nsg-db \
#   --resource-group multitierRG


echo "Configure Web Tier NSG Rule" ...

 echo "Allow Inbound HTTP from the Internet" ...
  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name WebVMNSG \
   --name Allow-HTTP-Inbound \
   --priority 100 \
   --direction Inbound \
   --access Allow \
   --protocol Tcp \
   --source-address-prefixes Internet \
   --source-port-ranges "*" \
   --destination-address-prefixes 10.0.1.0/24 \
   --destination-port-ranges 80

 echo "Allow Inbound HTTPS from the Internet" ...
  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name WebVMNSG \
   --name Allow-HTTPS-Inbound \
   --priority 110 \
   --direction Inbound \
   --access Allow \
   --protocol Tcp \
   --source-address-prefixes Internet \
   --source-port-ranges "*" \
   --destination-address-prefixes 10.0.1.0/24 \
   --destination-port-ranges 443

 echo "Allow Outbound Traffic to the Application Tier on Port 8080" ...
  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name WebVMNSG \
   --name Allow-To-AppTier \
   --priority 100 \
   --direction Outbound \
   --access Allow \
   --protocol Tcp \
   --source-address-prefixes 10.0.1.0/24 \
   --source-port-ranges "*" \
   --destination-address-prefixes 10.0.2.0/24 \
   --destination-port-ranges 8080

 echo "Deny Outbound Traffic to the DataBase Tier" ...
  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name WebVMNSG \
   --name Deny-To-DBTier \
   --priority 200 \
   --direction Outbound \
   --access Deny \
   --protocol "*" \
   --source-address-prefixes 10.0.1.0/24 \
   --source-port-ranges "*" \
   --destination-address-prefixes 10.0.3.0/24 \
   --destination-port-ranges "*"


echo "Configure Application Tier NSG Rule" ...

 echo "Allow Inbound from Web Tier on Port 8080" ...
  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name AppVMNSG \
   --name Allow-From-WebTier \
   --priority 100 \
   --direction Inbound \
   --access Allow \
   --protocol Tcp \
   --source-address-prefixes 10.0.1.0/24 \
   --source-port-ranges "*" \
   --destination-address-prefixes 10.0.2.0/24 \
   --destination-port-ranges 8080

 echo "Deny all other Inbound traffic from Vnet" ...
  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name AppVMNSG \
   --name Deny-All-Other-Inbound \
   --priority 4000 \
   --direction Inbound \
   --access Deny \
   --protocol "*" \
   --source-address-prefixes VirtualNetwork \
   --source-port-ranges "*" \
   --destination-address-prefixes 10.0.2.0/24 \
   --destination-port-ranges "*"

 echo "Allow Outbound to DataBase Tier on SQL Port" ...
  az network nsg rule create \
  --resource-group multitierRG \
  --nsg-name AppVMNSG \
  --name Allow-To-DBTier \
  --priority 100 \
  --direction Outbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes 10.0.2.0/24 \
  --source-port-ranges "*" \
  --destination-address-prefixes 10.0.3.0/24 \
  --destination-port-ranges 1433

 echo "Deny Outbound to Web Tier" ...
  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name AppVMNSG \
   --name Deny-To-WebTier \
   --priority 200 \
   --direction Outbound \
   --access Deny \
   --protocol Tcp \
   --source-address-prefixes 10.0.2.0/24 \
   --source-port-ranges "*" \
   --destination-address-prefixes 10.0.1.0/24 \
   --destination-port-ranges "*"


echo "Configure the DataBase Tier NSG Rule" ...

 echo "Allow Inbound from App Tier on SQL PORT only" ...
  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name DataBaseVMNSG \
   --name Allow-From-AppTier \
   --priority 100 \
   --direction Inbound \
   --access Allow \
   --protocol Tcp \
   --source-address-prefixes 10.0.2.0/24 \
   --source-port-ranges "*" \
   --destination-address-prefixes 10.0.3.0/24 \
   --destination-port-ranges 1433

 echo "Deny all other Inbound from VNET" ...
  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name DataBaseVMNSG \
   --name Deny-All-Other-Inbound \
   --priority 4000 \
   --direction Inbound \
   --access Deny \
   --protocol "*" \
   --source-address-prefixes VirtualNetwork \
   --source-port-ranges "*" \
   --destination-address-prefixes 10.0.3.0/24 \
   --destination-port-ranges "*"

 echo "Deny all Outbound to Internet" ...
  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name DataBaseVMNSG \
   --name Deny-Internet-Outbound \
   --priority 100 \
   --direction Outbound \
   --access Deny \
   --protocol "*" \
   --source-address-prefixes 10.0.3.0/24 \
   --source-port-ranges "*" \
   --destination-address-prefixes Internet \
   --destination-port-ranges "*"


echo "Associate NSGs with their respective subnets" ...
 az network vnet subnet update \
  --resource-group multitierRG \
  --vnet-name multitier-vnet \
  --name WebSubnet \
  --network-security-group WebVMNSG

 az network vnet subnet update \
  --resource-group multitierRG \
  --vnet-name multitier-vnet \
  --name AppSubnet \
  --network-security-group AppVMNSG

 az network vnet subnet update \
  --resource-group multitierRG \
  --vnet-name multitier-vnet \
  --name DataBaseSubnet \
  --network-security-group DataBaseVMNSG

echo "NSG Configurations successful !!!"