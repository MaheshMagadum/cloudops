resource "azurerm_resource_group" "rg" {
  name = "arogrp"
  location = var.location
}

provider "azapi" {
}
data "azuread_client_config" "current" {}
# data "azurerm_subscription" "current" {}

locals {
  resource_group_id = azurerm_resource_group.rg.id
  name_prefix = var.cluster-name
  pull_secret = var.pull_secret_path != null && var.pull_secret_path != "" ? file(var.pull_secret_path) : null
}
## Network resources
resource "azurerm_virtual_network" "rg" {
  name                = "${local.name_prefix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.aro_virtual_network_cidr_block]
}
# data "azuread_service_principal" "aro_resource_provisioner" {
#     display_name            = "Azure Red Hat OpenShift RP"
# }

# resource "azuread_application" "cluster" {
#     display_name            = "${local.name_prefix}-cluster-app"
#     owners                  = [data.azuread_client_config.current.object_id]
# }

# resource "azuread_application_password" "cluster" {
#     application_object_id   = azuread_application.cluster.object_id
# }

# resource "azuread_service_principal" "cluster" {
#     application_id  = azuread_application.cluster.application_id
#     owners          = [data.azuread_client_config.current.object_id]
# }

# resource "azurerm_role_assignment" "main" {
#         scope                   = data.azurerm_subscription.current.id
#         role_definition_name    = "Contributor"
#         principal_id            = azuread_service_principal.cluster.object_id
# }

# resource "azurerm_role_assignment" "vnet" {
#     scope                   = azurerm_virtual_network.rg.id
#     role_definition_name    = "Network Contributor"
#     principal_id            = data.azuread_service_principal.aro_resource_provisioner.object_id
# }

resource "azurerm_subnet" "master_subnet" {
  name                                           = "${local.name_prefix}-master-subnet"
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.rg.name
  address_prefixes                               = [var.aro_master_subnet_cidr_block]
  service_endpoints                              = ["Microsoft.Storage", "Microsoft.ContainerRegistry"]
  enforce_private_link_service_network_policies  = true
  enforce_private_link_endpoint_network_policies = true

}

resource "azurerm_subnet" "worker_subnet" {
  name                 = "${local.name_prefix}-worker-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.rg.name
  address_prefixes     = [var.aro_worker_subnet_cidr_block]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.ContainerRegistry"]
}
resource "azapi_resource" "aro_cluster" {
  name      = var.cluster-name
  location  = var.location
  parent_id = local.resource_group_id
  type      = "Microsoft.RedHatOpenShift/openShiftClusters@2022-04-01"

  body = jsonencode({
    properties = {
      clusterProfile = {
        domain               = var.domain
        fipsValidatedModules = "Disabled"
        resourceGroupId      = azurerm_resource_group.rg.id
        pullSecret           = local.pull_secret
      }
      networkProfile = {
        podCidr     = var.aro_pod_cidr_block
        serviceCidr = var.aro_service_cidr_block
      }
      servicePrincipalProfile = {
        clientId     = "<clientID"
        clientSecret = "<CClientSecret"
      }
      masterProfile = {
        vmSize           = var.main_vm_size
        subnetId         = azurerm_subnet.master_subnet.id
        #encryptionAtHost = var.master_encryption_at_host
      }
      workerProfiles = [
        {
          name             = "worker"
          vmSize           = var.worker_vm_size
          diskSizeGB       = 128
          subnetId         = azurerm_subnet.worker_subnet.id
          count            = var.worker_node_count
        }
      ]
      apiserverProfile = {
        visibility = var.api_server_profile
      }
      ingressProfiles = [
        {
          visibility = var.ingress_profile
        }
      ]
    }
  })

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
