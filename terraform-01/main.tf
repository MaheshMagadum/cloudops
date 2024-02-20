terraform {
    required_providers{
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~> 3.0.0"
        }
    }
    required_version=">=0.15.0"
}

provider  "azurerm" {
    features{}
}

# Define Azure Resources
resource "azurerm_resource_group" "main" {
    name = "first-tf-rg-centralindia"
    location = "centralindia"
}

resource "azurerm_virtual_network" "main" {
   name ="first-tf-vnet-centralindia"
   location = azurerm_resource_group.main.location
   resource_group_name = azurerm_resource_group.main.name
   address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "main" {
  name = "first-tf-subnet-centralindia"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name = azurerm_resource_group.main.name
  address_prefixes = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "internal" {
 name = "first-tf-nic-internal-centralindia"
 location = azurerm_resource_group.main.location
 resource_group_name = azurerm_resource_group.main.name
 ip_configuration {
   name = "internal"
   subnet_id = azurerm_subnet.main.id
   private_ip_address_allocation = "Dynamic"
 }
}

# Azure Windows Virtual Machine consuming the Resources

resource "azurerm_windows_virtual_machine" "main" {
  name = "first-tf-vm-in"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  # Standard_B1s is no more supported, use Standard_B2s
  size = "Standard_B2s"
  admin_username = "user.admin"
  admin_password = "<password>"

  network_interface_ids = [
     azurerm_network_interface.internal.id
  ]
  
  os_disk {
   caching = "ReadWrite"
   storage_account_type = "Standard_LRS"
  }

 source_image_reference {
   publisher = "MicrosoftwindowsServer"
   offer = "WindowsServer"
   sku = "2016-DataCenter"
   version = "latest"
 }
 
}
