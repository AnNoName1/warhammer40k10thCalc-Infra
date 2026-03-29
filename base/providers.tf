terraform {
  required_providers {
    kubernetes = {
      source  = "opentofu/kubernetes" # Вместо hashicorp/
      version = ">= 2.0.0"
    }
    helm = {
      source  = "registry.terraform.io/hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config" 
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}