output "vote_url" {
  description = "Vote application URL"
  value       = "http://10.144.208.102:${kubernetes_manifest.manifests["vote-service.yaml"].object.spec.ports[0].nodePort}"
}

output "result_url" {
  description = "Result application URL"
  value       = "http://10.144.208.102:${kubernetes_manifest.manifests["result-service.yaml"].object.spec.ports[0].nodePort}"
}
