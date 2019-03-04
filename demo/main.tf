# Resource group to hold the other resources we create
resource "azurerm_resource_group" "demo" {
  name = "demo-rg"
  location = "${var.location}"
}

# A virtual network resource in the resource group
resource "azurerm_virtual_network" "demo" {
  name = "demo-vnet"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  location = "${azurerm_resource_group.demo.location}"
  address_space = ["${var.cidr_range}"]
}
