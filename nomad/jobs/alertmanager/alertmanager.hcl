# Source: https://learn.hashicorp.com/tutorials/nomad/prometheus-metrics
# https://github.com/GuyBarros/nomad_jobs/blob/master/prometheus.nomad.tpl

job "alertmanager" {

  datacenters = ["dc1"]

  type = "service"

  group "alerting" {

    count = 1

    ephemeral_disk {
      size = 300
    }
    
    network {
      port "http" {
        static = 9093
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    service {
      name = "alertmanager"
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
        "traefik.http.routers.alertmanager.rule=PathPrefix(`/alertmanager`)",
        "traefik.http.middlewares.alertmanager-stripprefix.stripprefix.prefixes=/alertmanager",
        "traefik.http.middlewares.alertmanager-stripprefix.stripprefix.forceSlash=false",
        "traefik.http.routers.alertmanager.middlewares=alertmanager-stripprefix",
      ]        
    }

    task "alertmanager" {

      driver = "docker"

      config {
        image = "prom/alertmanager:v0.23.0"
        ports = ["http"]
      }

      resources {
        cpu    = 100
        memory = 100
      }

    }

  }

}