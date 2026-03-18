#!/bin/bash

## Writing a bash script to automate full deployment for Multi-Tier Architecture

set -e

trap 'echo "Deployment failed on line $LINENO. Check the error above."' ERR

# Create Resource Group for the MTA
. ./group.sh

# Create a Vnet with 3 Subnets [Web, App, DataBase]
. ./networks.sh

# Provision Linux VMs in each Subnet
. ./vm.sh

# Create NSGs for each tier to allow only necessary communications
. ./nsg.sh

echo "Deployment complete !!"

# Ping Tests for Subnet comms tests
. ./pingtest.sh

# SSH into each VM and verify connectivity rules