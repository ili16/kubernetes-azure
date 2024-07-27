# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.110.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "kubernetes-hard-way" {
  name     = "kubernetes-hard-way"
  location = "West Europe"
}

resource "azurerm_virtual_network" "kubernetes-network" {
  name                = "kubernetes-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.kubernetes-hard-way.location
  resource_group_name = azurerm_resource_group.kubernetes-hard-way.name
}

resource "azurerm_subnet" "kubernetes-subnet" {
  name                 = "kubernetes-subnet"
  resource_group_name  = azurerm_resource_group.kubernetes-hard-way.name
  virtual_network_name = azurerm_virtual_network.kubernetes-network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "jumpbox-nic" {
  name                = "jumpbox-nic"
  location            = azurerm_resource_group.kubernetes-hard-way.location
  resource_group_name = azurerm_resource_group.kubernetes-hard-way.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.kubernetes-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.0.2.5"
    public_ip_address_id = azurerm_public_ip.jumpbox_publicip.id
  }
}

resource "azurerm_public_ip" "server_publicip" {
  name                = "server_publicip"
  resource_group_name = azurerm_resource_group.kubernetes-hard-way.name
  location            = azurerm_resource_group.kubernetes-hard-way.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "server-nic" {
    name = "server-nic"
    location = azurerm_resource_group.kubernetes-hard-way.location
    resource_group_name = azurerm_resource_group.kubernetes-hard-way.name

    ip_configuration {
      name = "internal"
      subnet_id = azurerm_subnet.kubernetes-subnet.id
      private_ip_address_allocation = "Static"
      private_ip_address = "10.0.2.10"
      public_ip_address_id = azurerm_public_ip.server_publicip.id
    }
  
}


resource "azurerm_network_interface" "node-1-nic" {
    name = "node-1-nic"
    location = azurerm_resource_group.kubernetes-hard-way.location
    resource_group_name = azurerm_resource_group.kubernetes-hard-way.name

    ip_configuration {
      name = "internal"
      subnet_id = azurerm_subnet.kubernetes-subnet.id
      private_ip_address_allocation = "Static"
      private_ip_address = "10.0.2.20"
    }
}

resource "azurerm_network_interface" "node-0-nic" {
    name = "node-0-nic"
    location = azurerm_resource_group.kubernetes-hard-way.location
    resource_group_name = azurerm_resource_group.kubernetes-hard-way.name

    ip_configuration {
      name = "internal"
      subnet_id = azurerm_subnet.kubernetes-subnet.id
      private_ip_address_allocation = "Static"
      private_ip_address = "10.0.2.21"
    }
  
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                = "jumpbox"
  resource_group_name = azurerm_resource_group.kubernetes-hard-way.name
  location            = azurerm_resource_group.kubernetes-hard-way.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.jumpbox-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12-daily"
    sku       = "12"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "server" {
  name                = "server"
  resource_group_name = azurerm_resource_group.kubernetes-hard-way.name
  location            = azurerm_resource_group.kubernetes-hard-way.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.server-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12-daily"
    sku       = "12"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "node-1" {
  name                = "node-1"
  resource_group_name = azurerm_resource_group.kubernetes-hard-way.name
  location            = azurerm_resource_group.kubernetes-hard-way.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.node-1-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12-daily"
    sku       = "12"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "node-0" {
  name                = "node-0"
  resource_group_name = azurerm_resource_group.kubernetes-hard-way.name
  location            = azurerm_resource_group.kubernetes-hard-way.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.node-0-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12-daily"
    sku       = "12"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "jumpbox_publicip" {
  name                = "jumpbox_publicip"
  resource_group_name = azurerm_resource_group.kubernetes-hard-way.name
  location            = azurerm_resource_group.kubernetes-hard-way.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

output "jumpbox_public_ip" {
  value = azurerm_public_ip.jumpbox_publicip.ip_address
}

output "server_public_ip" {
  value = azurerm_public_ip.server_publicip.ip_address
}
