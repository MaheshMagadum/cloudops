terraform {
  required_version = ">=1.0.0"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}
provider "azurerm" {
  features{}
}

resource "azurerm_resource_group" "rg" {
  name = "dev-rg"
  location = var.location
}

resource "azurerm_virtual_network" "azure_vnet" {
  resource_group_name = azurerm_resource_group.rg.name
  name = "aro-vnet"
  location = azurerm_resource_group.rg.location
  address_space = ["10.0.4.0/25"]
}
resource "azurerm_subnet" "azure_subnet" {
  name = var.subnet_name
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.azure_vnet.name
  address_prefixes = ["10.0.4.0/29"]
}
# Create public IPs
resource "azurerm_public_ip" "public_IP" {
  name                = "public_IP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "azure_ni" {
  name = azurerm_virtual_network.azure_vnet.name
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name = "my_azure_ni"
    subnet_id = azurerm_subnet.azure_subnet.id
    private_ip_address_allocation = var.private_ip_allocation
    public_ip_address_id          = azurerm_public_ip.public_IP.id
  }
}
resource "azurerm_network_security_group" "nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "namehere" {
  network_interface_id      = azurerm_network_interface.azure_ni.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "azure_vm" {
  name = var.vm_name
  resource_group_name = azurerm_resource_group.rg.name
  location = var.location
  network_interface_ids = [azurerm_network_interface.azure_ni.id] 
  size                  = "Standard_B2s"

   os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

 source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  computer_name  = var.hostname
  admin_username = var.username
  admin_ssh_key {
    username   = var.username
    public_key = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
  }

}