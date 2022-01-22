# Source: https://learn.hashicorp.com/tutorials/nomad/prometheus-metrics

job "prometheus" {

  datacenters = ["dc1"]
  
  type        = "service"

  group "monitoring" {

    count = 1

    network {
      port "prometheus_ui" {
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

      template {
        change_mode = "noop"
        destination = "local/prometheus.yml"

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
    - server: '{{ env "NOMAD_IP_prometheus_ui" }}:8500'
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
      - targets: ['localhost:9090']

  # node-exporter metrics
  - job_name: 'node'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:9100']
        EOH
      }

      driver = "exec"

      config {
        command = "local/prometheus-2.32.1.linux-armv7/prometheus"
        args = [
          "--config.file=local/prometheus.yml"
        ]
      }

      artifact {
        source = "https://github.com/prometheus/prometheus/releases/download/v2.32.1/prometheus-2.32.1.linux-armv7.tar.gz"
        destination = "local"
        options { 
          checksum = "sha256:21d8a095f02b2986d408cff744e568ca66c92212b124673143b155a80284d2e4"
        }
      }

      service {
        name = "prometheus"
        tags = []
        port = "prometheus_ui"
        check {
          name     = "prometheus_ui port alive"
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 100
        memory = 100
      }

    }

  }

}