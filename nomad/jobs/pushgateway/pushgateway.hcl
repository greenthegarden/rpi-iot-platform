job "pushgateway" {

  datacenters = ["dc1"]

  type = "service"

  group "alerting" {

    count = 1

    ephemeral_disk {
      size = 300
    }
    
    network {
      port "http" {
        static = 9091
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    service {
      name = "pushgateway"
      port = "http"

      check {
        name     = "http port alive"
        type     = "http"
        path     = "/-/healthy"
        interval = "10s"
        timeout  = "2s"
      }

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.pushgateway.rule=PathPrefix(`/pushgateway`)",
        "traefik.http.middlewares.pushgateway-stripprefix.stripprefix.prefixes=/pushgateway",
        "traefik.http.middlewares.pushgateway-stripprefix.stripprefix.forceSlash=false",
        "traefik.http.routers.pushgateway.middlewares=pushgateway-stripprefix",
      ]        
    }

    task "pushgateway" {

      driver = "docker"

      config {
        image = "prom/pushgateway:v1.4.2"
        ports = ["http"]
      }

      resources {
        cpu    = 100
        memory = 100
      }

    }

  }

}