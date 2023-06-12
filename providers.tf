terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.59.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.18.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = var.region
}

provider "kubernetes" {
  # Configuration options
  #config_path = "~/.kube/config"
}

provider "helm" {
  # Configuration options
  kubernetes {
    # config_path = "~/.kube/config"
  }
}