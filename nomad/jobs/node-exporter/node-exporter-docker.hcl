job "node-exporter" {

  region = "global"
  
  datacenters = ["dc1"]
  
  type = "service"

  group "monitoring" {

    count = 1

    network {
      port "http" {
        static = 9100
      }
    }
    
    restart {
      attempts = 3
      delay    = "20s"
      mode     = "delay"
    }

    task "node-exporter" {

      driver = "docker"

      config {
        image = "prom/node-exporter:v1.3.1"

        force_pull = true

        // logging {
        //   type = "journald"
        //   config {
        //     tag = "NODE-EXPORTER"
        //   }
        // }

        // volumes = [
        //   "/proc:/host/proc",
        //   "/sys:/host/sys",
        //   "/:/rootfs"
        // ]

        mount {
          type = "bind"
          source = "/proc"
          target = "/host/proc"
          readonly = true
        }

        mount {
          type = "bind"
          source = "/sys"
          target = "/host/sys"
          readonly = true
        }

        mount {
          type = "bind"
          source = "/"
          target = "/rootfs"
          readonly = true
        }

        ports = ["http"]

      }

      resources {
        cpu    = 50
        memory = 100
      }

      service {
        name = "node-exporter"
        // address_mode = "driver"
        tags = [
          "metrics"
        ]
        port = "http"
        check {
          type = "http"
          path = "/metrics/"
          interval = "10s"
          timeout = "2s"
        }
      }

    }

  }

}
