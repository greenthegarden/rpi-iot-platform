# Treafik config source: https://blog.sethcorker.com/traefik-routing-for-web-apps/

job "emqx-edge" {

  region = "global"
  
  datacenters = ["dc1"]
  
  type = "service"

  group "middleware" {

    count = 1

    network {
      port "emqx_ui" {
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
      port = "emqx_ui"

      // check {
      //   type = "http"
      //   path = "/metrics/"
      //   interval = "10s"
      //   timeout = "2s"
      // }

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.emqx_ui.rule=Host(`iot.localdomain`) && PathPrefix(`/broker`)",
      ]
    }



    task "emqx-edge" {

      driver = "docker"

      config {
        image = "emqx/emqx-edge:4.3.10-alpine-arm32v7"
        // force_pull = true

        ports = ["mqtt", "emqx_ui"]        
      }

      env {
        PORT    = "${NOMAD_PORT_emqx_ui}"
        NODE_IP = "${NOMAD_IP_emqx_ui}"
      }

      resources {
        cpu    = 1400
        memory = 100
      }

    }

  }

}
