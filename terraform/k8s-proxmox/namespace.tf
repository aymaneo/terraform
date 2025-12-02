resource "kubernetes_namespace" "voting_app" {
  metadata {
    name = var.namespace
  }
}

