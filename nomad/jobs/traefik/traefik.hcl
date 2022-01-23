# Source: https://learn.hashicorp.com/tutorials/nomad/load-balancing-traefik?in=nomad/load-balancing

job "traefik" {

  region      = "global"
  
  datacenters = ["dc1"]
  
  type        = "service"

  group "traefik" {

    count = 1

    network {
      mode = "host"

      port "http" {
        static = 8080
      }

      port "api" {
        static = 8081
      }

      port "metrics" {
        static = 8082
      }
    }

    service {
      name = "traefik"

      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }

      port = "http"

      // tags = [
      //   "traefik.enable=true",
      //   "traefik.http.routers.dashboard.rule=Host(`traefik.localhost`)",
      //   "traefik.http.routers.dashboard.service=api@interal",
      //   "traefik.http.routers.dashboard.entrypoints=web",
      // ]
    }

    task "traefik" {
      driver = "docker"

      config {
        image        = "traefik:v2.6"
        // args = [
        //   "--entryPoints.http.address=:8080",
        //   "--accesslog=true",
        //   "--api=true",
        //   "--metrics=true",
        //   "--metrics.prometheus=true",
        //   "--metrics.prometheus.entryPoint=http",
        //   "--ping=true",
        //   "--ping.entryPoint=http",
        //   "--providers.consulcatalog=true",
        //   "--providers.consulcatalog.exposedByDefault=false",
        //   "--providers.consulcatalog.endpoint.address=127.0.0.1:8500",
        //   "--providers.consulcatalog.endpoint.scheme=http",
        //   "--providers.consulcatalog.prefix=traefik",
        // ]
        network_mode = "host"

        mount {
          type = "bind"
          source = "local/traefik.toml"
          target = "/etc/traefik/traefik.toml"
          readonly = true
        }

        ports = ["http", "api", "metrics"]
      }

      resources {
        cpu    = 100
        memory = 64
      }

      template {
        data = <<EOF
[entryPoints]
    [entryPoints.http]
    address = ":8080"
    [entryPoints.traefik]
    address = ":8081"
    [entryPoints.metrics]
    address = ":8082"

[api]
    dashboard = true
    insecure  = true

[log]
    level = "DEBUG"

# Enable Consul Catalog configuration backend.
[providers.consulCatalog]
    prefix           = "traefik"
    exposedByDefault = false

    [providers.consulCatalog.endpoint]
      address = "127.0.0.1:8500"
      scheme  = "http"
EOF

        destination = "local/traefik.toml"
      }

    }
  }
}