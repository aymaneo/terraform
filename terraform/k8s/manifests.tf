locals {
  manifest_files = {
    "pgsql-deployment.yaml"  = "pgsql-deployment.yaml"
    "pgsql-service.yaml"     = "pgsql-service.yaml"
    "redis-deployment.yaml"  = "redis-deployment.yaml"
    "redis-service.yaml"     = "redis-service.yaml"
    "result-deployment.yaml" = "result-deployment.yaml"
    "result-service.yaml"    = "result-service.yaml"
    "seed-job.yaml"          = "seed-job.yaml"
    "vote-deployment.yaml"   = "vote-deployment.yaml"
    "vote-service.yaml"      = "vote-service.yaml"
    "worker-deployment.yaml" = "worker-deployment.yaml"
  }
}

locals {
  processed_manifests = {
    for k, v in local.manifest_files : k => (
      k == "pgsql-deployment.yaml" ?
      replace(
        replace(
          file("${local.manifest_dir}/${v}"),
          "namespace: xyz",
          "namespace: ${var.namespace}"
        ),
        "        persistentVolumeClaim:\n          claimName: db-data-claim",
        "        emptyDir: {}"
      ) :
      replace(
        file("${local.manifest_dir}/${v}"),
        "namespace: xyz",
        "namespace: ${var.namespace}"
      )
    )
  }
}

resource "kubernetes_manifest" "manifests" {
  for_each = local.manifest_files

  manifest = yamldecode(local.processed_manifests[each.key])

  depends_on = [kubernetes_namespace.voting_app]
}
