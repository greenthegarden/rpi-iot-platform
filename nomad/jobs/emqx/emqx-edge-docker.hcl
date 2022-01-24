# Treafik config source: https://blog.sethcorker.com/traefik-routing-for-web-apps/

job "emqx-edge" {

  region = "global"
  
  datacenters = ["dc1"]
  
  type = "service"

  group "middleware" {

    count = 1

    network {
      port "http" {
        to = 18083
      }
      port "mqtt" {
        static = 1883
      }
    }
        
    restart {
      attempts = 3
      delay    = "20s"
      mode     = "delay"
    }
        
    service {
      name = "emqx-edge"
      port = "http"

      // check {
      //   type = "http"
      //   path = "/metrics/"
      //   interval = "10s"
      //   timeout = "2s"
      // }

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.emqx.service=emqx-edge",
        "traefik.http.routers.emqx.rule=PathPrefix(`/broker`)",
        "traefik.http.middlewares.emqx-stripprefix.stripprefix.prefixes=/broker",
        "traefik.http.middlewares.emqx-stripprefix.stripprefix.forceSlash=false",
        "traefik.http.routers.emqx.middlewares=emqx-stripprefix",
      ]
    }

    task "emqx-edge" {

      driver = "docker"

      config {
        image = "emqx/emqx-edge:4.3.10-alpine-arm32v7"
        // force_pull = true

        ports = ["http", "mqtt"]        
      }

      resources {
        cpu    = 1400
        memory = 100
      }

    }

  }

}
