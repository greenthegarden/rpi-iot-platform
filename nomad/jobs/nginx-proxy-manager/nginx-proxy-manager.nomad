job "nginx-proxy-manager" {

  region = "global"

  datacenters = [
    "dc1",
  ]

  type = "service"

  group "ingress" {

    count = 1

    network {
      port "http" {
        static = 80
      }

      port "manager" {
        static = 81
      }

      port "https" {
        static = 443
      }
    }

    restart {
      attempts = 5
      delay    = "15s"
    }

    service {
      name = "nginx-proxy-manager"
      port = "http"

      check {
        type     = "http"
        path     = "/"
        interval = "2s"
        timeout  = "2s"
      }      
    }

    task "nginx" {

      driver = "docker"

      config {
        image = "jc21/nginx-proxy-manager:latest"

        ports = ["http", "https", "manager"]
      }

      resources {
        cpu    = 100
        memory = 64
      }


    }
  }
}