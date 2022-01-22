# Source: https://learn.hashicorp.com/tutorials/nomad/prometheus-metrics

job "fabio" {

  datacenters = ["dc1"]
  
  type = "system"

  group "fabio" {

    count = 1

    network {
      port "lb" {
        static = 9999
      }
      port "ui" {
        static = 9998
      }
    }

    task "fabio" {

      driver = "docker"

      config {
        image = "fabiolb/fabio"
        network_mode = "host"
        ports = ["lb", "ui"]
      }

      resources {
        cpu    = 100
        memory = 32
      }

    }

  }
  
}