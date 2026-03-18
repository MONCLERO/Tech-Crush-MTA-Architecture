echo "Web Tier NSG - Allow ping to App ONLY"

   az network nsg rule create \
    --resource-group multitierRG \
    --nsg-name WebVMNSG \
    --name Allow-ICMP-To-App \
    --priority 120 \
    --direction Outbound \
    --access Allow \
    --protocol Icmp \
    --source-address-prefixes 10.0.1.0/24 \
    --destination-address-prefixes 10.0.2.0/24

echo "App Tier NSG - Allow ping from Web AND to DB"

  echo Allow Web --> App ping
   az network nsg rule create \
    --resource-group multitierRG \
    --nsg-name AppVMNSG \
    --name Allow-ICMP-From-Web \
    --priority 120 \
    --direction Inbound \
    --access Allow \
    --protocol Icmp \
    --source-address-prefixes 10.0.1.0/24 \
    --destination-address-prefixes 10.0.2.0/24

  echo Allow App --> DB ping
   az network nsg rule create \
    --resource-group multitierRG \
    --nsg-name AppVMNSG \
    --name Allow-ICMP-To-DB \
    --priority 130 \
    --direction Outbound \
    --access Allow \
    --protocol Icmp \
    --source-address-prefixes 10.0.2.0/24 \
    --destination-address-prefixes 10.0.3.0/24

echo "DataBase Tier NSG - Allow ping ONLY from APP"

  az network nsg rule create \
   --resource-group multitierRG \
   --nsg-name DataBaseVMNSG \
   --name Allow-ICMP-From-App \
   --priority 120 \
   --direction Inbound \
   --access Allow \
   --protocol Icmp \
   --source-address-prefixes 10.0.2.0/24 \
   --destination-address-prefixes 10.0.3.0/24

echo "ICMP configuration completed !!!"