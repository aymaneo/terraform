terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "front_tier" {
  name = "front-tier"
}

resource "docker_network" "back_tier" {
  name = "back-tier"
}

resource "docker_volume" "db_data" {
  name = "db-data"
}

resource "docker_image" "redis" {
  name = "redis:alpine"
}

resource "docker_container" "redis" {
  name  = "redis"
  image = docker_image.redis.image_id

  networks_advanced {
    name = docker_network.back_tier.name
  }

  healthcheck {
    test     = ["CMD", "sh", "/healthchecks/redis.sh"]
    interval = "5s"
  }

  volumes {
    host_path      = abspath("${path.module}/../../healthchecks")
    container_path = "/healthchecks"
  }
}

resource "docker_image" "postgres" {
  name = "postgres:15-alpine"
}

resource "docker_container" "db" {
  name  = "db"
  image = docker_image.postgres.image_id

  networks_advanced {
    name = docker_network.back_tier.name
  }

  env = [
    "POSTGRES_PASSWORD=postgres"
  ]

  healthcheck {
    test     = ["CMD", "sh", "/healthchecks/postgres.sh"]
    interval = "5s"
  }

  volumes {
    volume_name    = docker_volume.db_data.name
    container_path = "/var/lib/postgresql/data"
  }

  volumes {
    host_path      = abspath("${path.module}/../../healthchecks")
    container_path = "/healthchecks"
  }
}

resource "docker_image" "vote" {
  name = "vote:latest"
  build {
    context = abspath("${path.module}/../../voting-services/vote")
  }
}

resource "docker_container" "vote1" {
  name  = "vote1"
  image = docker_image.vote.image_id

  networks_advanced {
    name = docker_network.front_tier.name
  }

  networks_advanced {
    name = docker_network.back_tier.name
  }

  healthcheck {
    test         = ["CMD", "curl", "-f", "http://localhost:5000"]
    interval     = "15s"
    timeout      = "5s"
    retries      = 2
    start_period = "5s"
  }

  depends_on = [docker_container.redis]
}

resource "docker_container" "vote2" {
  name  = "vote2"
  image = docker_image.vote.image_id

  networks_advanced {
    name = docker_network.front_tier.name
  }

  networks_advanced {
    name = docker_network.back_tier.name
  }

  healthcheck {
    test         = ["CMD", "curl", "-f", "http://localhost:5000"]
    interval     = "15s"
    timeout      = "5s"
    retries      = 2
    start_period = "5s"
  }

  depends_on = [docker_container.redis]
}

resource "docker_image" "result" {
  name = "result:latest"
  build {
    context = abspath("${path.module}/../../voting-services/result")
  }
}

resource "docker_container" "result" {
  name  = "result"
  image = docker_image.result.image_id

  networks_advanced {
    name = docker_network.front_tier.name
  }

  networks_advanced {
    name = docker_network.back_tier.name
  }

  ports {
    internal = 80
    external = 5050
  }

  ports {
    internal = 9229
    external = 9229
  }

  depends_on = [docker_container.db]
}

resource "docker_image" "worker" {
  name = "worker:latest"
  build {
    context = abspath("${path.module}/../../voting-services/worker")
  }
}

resource "docker_container" "worker" {
  name  = "worker"
  image = docker_image.worker.image_id

  networks_advanced {
    name = docker_network.back_tier.name
  }

  depends_on = [docker_container.redis, docker_container.db]
}

resource "docker_image" "nginx" {
  name = "nginx:latest"
  build {
    context = abspath("${path.module}/../../voting-services/nginx")
  }
}

resource "docker_container" "nginx" {
  name  = "nginx"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.front_tier.name
  }

  ports {
    internal = 8000
    external = 8000
  }

  depends_on = [docker_container.vote1, docker_container.vote2]
}

resource "docker_image" "seed" {
  name = "seed-data:latest"
  build {
    context = abspath("${path.module}/../../voting-services/seed-data")
  }
}

resource "docker_container" "seed" {
  name  = "seed"
  image = docker_image.seed.image_id

  networks_advanced {
    name = docker_network.front_tier.name
  }

  env = [
    "TARGET_HOST=nginx",
    "TARGET_PORT=8000"
  ]

  restart = "no"

  depends_on = [docker_container.nginx]
}

