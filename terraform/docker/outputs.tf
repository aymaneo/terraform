output "vote_nginx_loadbalancer_url" {
  description = "URL to vote service nginx load balancer"
  value       = "http://localhost:${docker_container.nginx.ports[0].external}"
}

output "result_url" {
  description = "URL to results page"
  value       = "http://localhost:${docker_container.result.ports[0].external}"
}