echo "Web Tier NSG - Allow ping to App ONLY"

   az network nsg rule create \
    --resource-group multitierRG \
    --nsg-name MTA-NSG \
    --name Allow-ICMP-To-App \
    --priority 170 \
    --direction Outbound \
    --access Allow \
    --protocol Icmp \
    --source-address-prefixes 10.0.1.0/24 \
    --destination-address-prefixes 10.0.2.0/24

echo "App Tier NSG - Allow ping from Web AND to DB"

  echo Receives ping from Web
   az network nsg rule create \
    --resource-group multitierRG \
    --nsg-name MTA-NSG \
    --name Allow-ICMP-From-Web \
    --priority 180 \
    --direction Inbound \
    --access Allow \
    --protocol Icmp \
    --source-address-prefixes 10.0.1.0/24 \
    --destination-address-prefixes 10.0.2.0/24

  echo Allow App ping DB
   az network nsg rule create \
    --resource-group multitierRG \
    --nsg-name MTA-NSG \
    --name Allow-ICMP-To-DB \
    --priority 185 \
    --direction Outbound \
    --access Allow \
    --protocol Icmp \
    --source-address-prefixes 10.0.2.0/24 \
    --destination-address-prefixes 10.0.3.0/24

echo "DataBase Tier NSG - Receives ping ONLY from App"

  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name MTA-NSG \
   --name Allow-ICMP-From-App \
   --priority 190 \
   --direction Inbound \
   --access Allow \
   --protocol Icmp \
   --source-address-prefixes 10.0.2.0/24 \
   --destination-address-prefixes 10.0.3.0/24

echo "ICMP configuration completed !!!"