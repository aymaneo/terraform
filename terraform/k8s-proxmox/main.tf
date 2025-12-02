terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path = pathexpand(var.kubeconfig_path)
}

variable "namespace" {
  type    = string
  default = "a23ouraq"
}

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  default     = "~/.kube/config"
}

locals {
  manifest_dir = "${path.module}/../../k8s-proxmox-manifests"
}

