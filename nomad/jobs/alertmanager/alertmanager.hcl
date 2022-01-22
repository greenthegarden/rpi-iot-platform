# Source: https://learn.hashicorp.com/tutorials/nomad/prometheus-metrics
# https://github.com/GuyBarros/nomad_jobs/blob/master/prometheus.nomad.tpl

job "alertmanager" {

  datacenters = ["dc1"]

  type = "service"

  group "alerting" {

    count = 1

    network {
      port "alertmanager_ui" {
        static = 9093
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "alertmanager" {

      driver = "docker"

      config {
        image = "prom/alertmanager:v0.23.0"
        ports = ["alertmanager_ui"]
      }

      resources {
        cpu    = 100
        memory = 100
      }

      service {
        name = "alertmanager"
        tags = ["urlprefix-/alertmanager strip=/alertmanager"]
        port = "alertmanager_ui"
        check {
          name     = "alertmanager_ui port alive"
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }

    }

  }

}