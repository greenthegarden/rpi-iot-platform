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
        
    task "emqx-edge" {

      driver = "docker"

      config {
        image = "emqx/emqx-edge:4.3.10-alpine-arm32v7"
        // force_pull = true

        ports = ["mqtt", "http"]
        
        // logging {
        //   type = "journald"
        //   config {
        //     tag = "NODE-EXPORTER"
        //   }
        // }

      }

      service {
        name = "emqx-edge"
        tags = ["mqtt", "http"]
        port = "http"

        // check {
        //   type = "http"
        //   path = "/metrics/"
        //   interval = "10s"
        //   timeout = "2s"
        // }
      }

      resources {
        cpu    = 1400
        memory = 100
      }

    }

  }

}
