terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path = pathexpand("~/.kube/config")
}

variable "namespace" {
  type    = string
  default = "a23ouraq"
}

locals {
  manifest_dir = "${path.module}/../../k8s-manifests"
}

