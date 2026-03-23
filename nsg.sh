echo "Create NSG for each tier to allow only necessary communications" ...

  az network nsg create \
   --name MTA-NSG \
   --resource-group multitierRG

#  az network nsg create \
#   --name nsgapp \
#   --resource-group multitierRG

#  az network nsg create \
#   --name nsg-db \
#   --resource-group multitierRG

echo "default-allow-SSH"
 
  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name MTA-NSG \
   --name Allow-SSH \
   --priority 100 \
   --direction Inbound \
   --access Allow \
   --protocol Tcp \
   --source-address-prefixes "*" \
   --source-port-ranges "*" \
   --destination-port-ranges 22

echo "Configure Web Tier NSG Rule" ...

 echo "Allow Inbound HTTP from the Internet" ...
  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name MTA-NSG \
   --name Allow-HTTP-Inbound \
   --priority 110 \
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
   --nsg-name MTA-NSG \
   --name Allow-HTTPS-Inbound \
   --priority 120 \
   --direction Inbound \
   --access Allow \
   --protocol Tcp \
   --source-address-prefixes Internet \
   --source-port-ranges "*" \
   --destination-address-prefixes 10.0.1.0/24 \
   --destination-port-ranges 443

 echo "Allow Outbound Traffic to the Application Tier on Port 8080" ... # Pairing practice
  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name MTA-NSG \
   --name Allow-To-AppTier \
   --priority 130 \
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
   --nsg-name MTA-NSG \
   --name Deny-To-DBTier \
   --priority 500 \
   --direction Outbound \
   --access Deny \
   --protocol "*" \
   --source-address-prefixes 10.0.1.0/24 \
   --source-port-ranges "*" \
   --destination-address-prefixes 10.0.3.0/24 \
   --destination-port-ranges "*"

echo "Configure Application Tier NSG Rule" ...

 echo "Allow Inbound from Web Tier on Port 8080" ...  #Pairing Practice
  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name MTA-NSG \
   --name Allow-From-WebTier \
   --priority 140 \
   --direction Inbound \
   --access Allow \
   --protocol Tcp \
   --source-address-prefixes 10.0.1.0/24 \
   --source-port-ranges "*" \
   --destination-address-prefixes 10.0.2.0/24 \
   --destination-port-ranges 8080

 echo "Allow Outbound to DataBase Tier on SQL Port" ...
  az network nsg rule create \
  --resource-group multitierRG \
  --nsg-name MTA-NSG \
  --name Allow-To-DBTier \
  --priority 150 \
  --direction Outbound \
  --access Allow \
  --protocol "*" \
  --source-address-prefixes 10.0.2.0/24 \
  --source-port-ranges "*" \
  --destination-address-prefixes 10.0.3.0/24 \
  --destination-port-ranges 1433

 echo "Deny all other Inbound traffic from Vnet" ...
  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name MTA-NSG \
   --name Deny-All-Other-Inbound \
   --priority 4000 \
   --direction Inbound \
   --access Deny \
   --protocol "*" \
   --source-address-prefixes VirtualNetwork \
   --source-port-ranges "*" \
   --destination-address-prefixes 10.0.2.0/24 \
   --destination-port-ranges "*"

 echo "Deny Outbound to Web Tier" ...
  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name MTA-NSG \
   --name Deny-To-WebTier \
   --priority 3900 \
   --direction Outbound \
   --access Deny \
   --protocol "*" \
   --source-address-prefixes 10.0.2.0/24 \
   --source-port-ranges "*" \
   --destination-address-prefixes 10.0.1.0/24 \
   --destination-port-ranges "*"

echo "Configure the DataBase Tier NSG Rule" ...

 echo "Allow Inbound from App Tier on SQL PORT only" ...
  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name MTA-NSG \
   --name Allow-From-AppTier \
   --priority 160 \
   --direction Inbound \
   --access Allow \
   --protocol "*" \
   --source-address-prefixes 10.0.2.0/24 \
   --source-port-ranges "*" \
   --destination-address-prefixes 10.0.3.0/24 \
   --destination-port-ranges 1433

 echo "Deny all other Inbound from VNET" ...
  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name MTA-NSG \
   --name Deny-All-Other-Inbound \
   --priority 4001 \
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
   --nsg-name MTA-NSG \
   --name Deny-Internet-Outbound \
   --priority 4002 \
   --direction Outbound \
   --access Deny \
   --protocol "*" \
   --source-address-prefixes 10.0.3.0/24 \
   --source-port-ranges "*" \
   --destination-address-prefixes "Internet" \
   --destination-port-ranges "*"

echo "Associate NSG with all subnets..."
   SUBNETS=("WebSubnet" "AppSubnet" "DataBaseSubnet")

   for SUBNET in "${SUBNETS[@]}"; do
  echo "Attaching MTA-NSG to $SUBNET..."
 az network vnet subnet update \
  --resource-group multitierRG \
  --vnet-name multitier-vnet \
  --name $SUBNET \
  --network-security-group MTA-NSG
  echo "SUBNET attached to NSG successfully !!!"
   done

#  az network vnet subnet update \
#   --resource-group multitierRG \
#   --vnet-name multitier-vnet \
#   --name AppSubnet \
#   --network-security-group AppVMNSG

#  az network vnet subnet update \
#   --resource-group multitierRG \
#   --vnet-name multitier-vnet \
#   --name DataBaseSubnet \
#   --network-security-group DataBaseVMNSG

echo "NSG Configurations successful !!!"