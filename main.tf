resource "azurerm_resource_group" "myrg" {
    name = "rr-rg"
    location = "westeurope"
  
}


resource "azurerm_virtual_network" "myvnet" {
    name = "r-vnet"
    resource_group_name = azurerm_resource_group.myrg.name
    location = azurerm_resource_group.myrg.location
    address_space = ["10.0.0.0/16"]
 
}

resource "azurerm_subnet" "mysubnet" {
    name = "vm-submet"
    resource_group_name = azurerm_resource_group.myrg.name
    virtual_network_name = azurerm_virtual_network.myvnet.name
    address_prefixes = ["10.0.1.0/24"]
  
}



resource "azurerm_public_ip" "mypublic-ip" {
  name                = "rr-publicip"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  allocation_method   = "Static"

}

resource "azurerm_network_interface" "mynic" {
  name                = "rr-nic"
  location            = "westeurope"
  resource_group_name = "rr-rg"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          =  azurerm_public_ip.mypublic-ip.id    
  }
}



resource "azurerm_virtual_machine" "myvm" {
  name                  = "rr-vm"
  location              = azurerm_resource_group.myrg.location
  resource_group_name   = azurerm_resource_group.myrg.name
  network_interface_ids = [azurerm_network_interface.mynic.id]
  vm_size               = "Standard_D2s_v3"


  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "mycloudvm"
    admin_username = "userrajesh"
    admin_password = "Password@123"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  
}
