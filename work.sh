#!/bin/bash

set -e

#Writing a bash script to automate full deployment for Multi-Tier Architecture

#Create Resource Group for the MTA
az group create --name multitierRG --location southafricanorth

#Create a Vnet with 3 Subnets [Web, App, DataBase]
az network vnet create --name multitier-vnet --resource-group multitierRG --address-prefixes 10.0.0.0/16 --subnet-name WebSubnet --subnet-prefixes 10.0.1.0/24
az network vnet subnet create --name AppSubnet --resource-group multitierRG --vnet-name multitier-vnet --address-prefixes 10.0.2.0/24
az network vnet subnet create --name DataBaseSubnet --resource-group multitierRG --vnet-name multitier-vnet --address-prefixes 10.0.3.0/24

#Provision Linux VMs in each Subnet
az vm create --name WebVM --resource-group multitierRG --image Ubuntu2404 --vnet-name multitier-vnet --subnet WebSubnet --authentication-type password --admin-username webvirtual --admin-password Password@meziky303
az vm create --name AppVM --resource-group multitierRG --image Ubuntu2404 --vnet-name multitier-vnet --subnet AppSubnet --authentication-type password --admin-username appvirtual --admin-password Password@meziky303
az vm create --name DataBaseVM --resource-group multitierRG --image Ubuntu2204 --vnet-name multitier-vnet --subnet DataBaseSubnet --authentication-type password --admin-username dbvirtual --admin-password Password@meziky303

#Create NSGs for each tier to allow only necessary communications
az network nsg create --name nsgweb --resource-group multitierRG
az network nsg create --name nsgapp --resource-group multitierRG
az network nsg create --name nsg-db --resource-group multitierRG


#Configure Web Tier NSG Rule

#Allow Inbound [INCOMING] HTTP from the Internet
az network nsg rule create --resource-group multitierRG --nsg-name nsgweb --name Allow-HTTP-Inbound --priority 100 --direction Inbound --access Allow --protocol Tcp --source-address-prefixes Internet --source-port-ranges "*" --destination-address-prefixes 10.0.1.0/24 --destination-port-ranges 80

#Allow Inbound HTTPS from the Internet
az network nsg rule create --resource-group multitierRG --nsg-name nsgweb --name Allow-HTTPS-Inbound --priority 110 --direction Inbound --access Allow --protocol Tcp --source-address-prefixes Internet --source-port-ranges "*" --destination-address-prefixes 10.0.1.0/24 --destination-port-ranges 443

#Allow Outbound Traffic to the Application Tier on Port 8080
az network nsg rule create --resource-group multitierRG --nsg-name nsgweb --name Allow-To-AppTier --priority 100 --direction Outbound --access Allow --protocol Tcp --source-address-prefixes 10.0.1.0/24 --source-port-ranges "*" --destination-address-prefixes 10.0.2.0/24 --destination-port-ranges 8080

#Deny Outbound Traffic to the DataBase Tier
az network nsg rule create --resource-group multitierRG --nsg-name nsgweb --name Deny-To-DBTier --priority 200 --direction Outbound --access Deny --protocol "*" --source-address-prefixes 10.0.1.0/24 --source-port-ranges "*" --destination-address-prefixes 10.0.3.0/24 --destination-port-ranges "*"



#Configure Application Tier NSG Rule

#Allow Inbound from Web Tier on Port 8080
az network nsg rule create --resource-group multitierRG --nsg-name nsgapp --name Allow-From-WebTier --priority 100 --direction Inbound --access Allow --protocol Tcp --source-address-prefixes 10.0.1.0/24 --source-port-ranges "*" --destination-address-prefixes 10.0.2.0/24 --destination-port-ranges 8080

#Deny all other Inbound traffic from Vnet
az network nsg rule create --resource-group multitierRG --nsg-name nsgapp --name Deny-All-Other-Inbound --priority 4000 --direction Inbound --access Deny --protocol "*" --source-address-prefixes VirtualNetwork --source-port-ranges "*" --destination-address-prefixes 10.0.2.0/24 --destination-port-ranges "*"

#Allow Outbound to DataBase Tier on SQL Port
az network nsg rule create --resource-group multitierRG --nsg-name nsgapp --name Allow-To-DBTier --priority 100 --direction Outbound --access Allow --protocol Tcp --source-address-prefixes 10.0.2.0/24 --source-port-ranges "*" --destination-address-prefixes 10.0.3.0/24 --destination-port-ranges 1433

#Deny Outbound to Web Tier
az network nsg rule create --resource-group multitierRG --nsg-name nsgapp --name Deny-To-WebTier --priority 200 --direction Outbound --access Deny --protocol Tcp --source-address-prefixes 10.0.2.0/24 --source-port-ranges "*" --destination-address-prefixes 10.0.1.0/24 --destination-port-ranges "*"



#Configure the DataBase Tier NSG Rule

#Allow Inbound from App Tier on SQL PORT only
az network nsg rule create --resource-group multitierRG --nsg-name nsg-db --name Allow-From-AppTier --priority 100 --direction Inbound --access Allow --protocol Tcp --source-address-prefixes 10.0.2.0/24 --source-port-ranges "*" --destination-address-prefixes 10.0.3.0/24 --destination-port-ranges 1433

#Deny all other Inbound from VNET
az network nsg rule create --resource-group multitierRG --nsg-name nsg-db --name Deny-All-Other-Inbound --priority 4000 --direction Inbound --access Deny --protocol "*" --source-address-prefixes VirtualNetwork --source-port-ranges "*" --destination-address-prefixes 10.0.3.0/24 --destination-port-ranges "*"

#Deny all Outbound to Internet
az network nsg rule create --resource-group multitierRG --nsg-name nsg-db --name Deny-Internet-Outbound --priority 100 --direction Outbound --access Deny --protocol "*" --source-address-prefixes 10.0.3.0/24 --source-port-ranges "*" --destination-address-prefixes Internet --destination-port-ranges "*"


#Associate NSGs with their respective subnets
az network vnet subnet update --resource-group multitierRG --vnet-name multitier-vnet --name WebSubnet --network-security-group nsgweb
az network vnet subnet update --resource-group multitierRG --vnet-name multitier-vnet --name AppSubnet --network-security-group nsgapp
az network vnet subnet update --resource-group multitierRG --vnet-name multitier-vnet --name DataBaseSubnet --network-security-group nsg-db



#Verifying Traffic Flow with Network Watcher IP

#Test if web tier can reach app tier on port 8080 (should be allowed)
az network watcher test-ip-flow --resource-group multitierRG --vm WebVM --direction Outbound --protocol Tcp --local 10.0.1.4:* --remote 10.0.2.4:8080

#Test if web tier can reach db tier on port 1433 (should be denied)
az network watcher test-ip-flow --resource-group multitierRG --vm WebVM --direction Outbound --protocol Tcp --local 10.0.1.4:* --remote 10.0.3.4:1433



#PingTests for Subnet comms tests
#SSH into each VM and verify connectivity rules