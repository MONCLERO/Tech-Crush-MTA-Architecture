echo "Creating Vnets with 3 Subnets - Web, App, DataBase" ...

 echo "Creating WebSubnet" ....

  az network vnet create \
   --name multitier-vnet \
   --resource-group multitierRG \
   --address-prefixes 10.0.0.0/16 \
   --subnet-name WebSubnet \
   --subnet-prefixes 10.0.1.0/24

 
 echo "Creating AppSubnet" ...

  az network vnet subnet create \
   --name AppSubnet \
   --resource-group multitierRG \
   --vnet-name multitier-vnet \
   --address-prefixes 10.0.2.0/24

 
 echo "Creating DataBaseSubnet" ...

  az network vnet subnet create \
   --name DataBaseSubnet \
   --resource-group multitierRG \
   --vnet-name multitier-vnet \
   --address-prefixes 10.0.3.0/24


echo "Network resource deployments successful !!!"