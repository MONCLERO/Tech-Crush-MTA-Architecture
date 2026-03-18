echo "Provision Linux VMs in each Subnet" ...

 echo "Creating WebVM" ...
  
  az vm create \
   --name WebVM \
   --resource-group multitierRG \
   --image Ubuntu2404 \
   --vnet-name multitier-vnet \
   --subnet WebSubnet \
   --authentication-type password \
   --admin-username webvirtual \
   --generate-ssh-keys

 echo "Creating AppVM" ... 
  
  az vm create \
   --name AppVM \
   --resource-group multitierRG \
   --image Ubuntu2404 \
   --vnet-name multitier-vnet \
   --subnet AppSubnet \
   --authentication-type password \
   --admin-username appvirtual \
   --generate-ssh-keys

 echo "Creating DataBaseVM" ...  
  
  az vm create \
   --name DataBaseVM \
   --resource-group multitierRG \
   --image Ubuntu2204 \
   --vnet-name multitier-vnet \
   --subnet DataBaseSubnet \
   --authentication-type password \
   --admin-username dbvirtual \
   --generate-ssh-keys

echo "Linux VM creation complete !!!"   