terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0" # Assurez-vous que cette version est compatible et récente
    }
  }
  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

resource "random_integer" "unique_suffix" {
  min = 10000
  max = 99999
}

variable "nom_prenom" {
  type        = string
  default     = "john_doe" # Valeur par défaut pour permettre des tests immédiats
  description = "Nom et prénom utilisé pour générer des noms de ressources uniques"
}

# Crée un groupe de ressources
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.nom_prenom}-${random_integer.unique_suffix.result}"
  location = "West Europe" # Assurez-vous que la localisation est celle désirée
}

# Crée un plan d'app service
resource "azurerm_service_plan" "asp" {
  name                = "asp-${var.nom_prenom}-${random_integer.unique_suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1" # B1 est un SKU de base, ajustez selon les besoins
}

# Crée une web app Linux
resource "azurerm_linux_web_app" "webapp" {
  name                = "webapp-${var.nom_prenom}-${random_integer.unique_suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    application_stack {
      java_version           = "11"
      java_container         = "TOMCAT"
      java_container_version = "9.0"
    }
  }
}
