# Source: https://learn.hashicorp.com/tutorials/nomad/prometheus-metrics
# https://github.com/GuyBarros/nomad_jobs/blob/master/prometheus.nomad.tpl

job "prometheus" {

  region = "global"

  datacenters = ["dc1"]
  
  type        = "service"

  group "monitoring" {

    count = 1

    network {
      port "http" {
        static = 9090
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "prometheus" {

      driver = "docker"

      config {
        image = "prom/node-exporter:v1.3.1"

        mount {
          type   = "bind"
          source = "local/prometheus.yml"
          target = "/etc/prometheus/prometheus.yml"
          readonly = true
        }

        ports = ["http"]

      }
        
      template {
        change_mode = "noop"
        data = <<EOH
---
global:
  scrape_interval:     15s
  evaluation_interval: 15s

  external_labels:
    monitor: 'iot-monitor'

scrape_configs:

  # nomad metrics
  - job_name: 'nomad_metrics'

    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_http" }}:8500'
      services: ['nomad-client', 'nomad']

    relabel_configs:
    - source_labels: ['__meta_consul_tags']
      regex: '(.*)http(.*)'
      action: keep

    scrape_interval: 5s
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']

  # consul metrics
  - job_name: 'consul_metrics'
    scheme: 'http'

    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_http" }}:8500'
      services:
        - 'consul'

  # prometheus metrics
  - job_name: 'prometheus'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['{{ env "NOMAD_IP_http" }}:9090']

  # node-exporter metrics
  - job_name: 'node'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['{{ env "NOMAD_IP_http" }}:9100']
EOH
        destination = "local/prometheus.yml"
      }

      resources {
        cpu    = 100
        memory = 100
      }

      service {
        name = "prometheus"
        tags = []
        port = "http"
        // check {
        //   name     = "http port alive"
        //   type     = "http"
        //   path     = "/-/healthy"
        //   interval = "10s"
        //   timeout  = "2s"
        // }
      }

    }

  }

}