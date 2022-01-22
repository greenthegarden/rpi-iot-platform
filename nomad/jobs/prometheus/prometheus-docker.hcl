# Source: https://learn.hashicorp.com/tutorials/nomad/prometheus-metrics
# https://github.com/GuyBarros/nomad_jobs/blob/master/prometheus.nomad.tpl

job "prometheus" {

  region = "global"

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

      driver = "docker"

      config {
        image = "prom/prometheus:v2.32.1"

        mount {
          type   = "bind"
          source = "local/prometheus.yml"
          target = "/etc/prometheus/prometheus.yml"
          readonly = true
        }

        mount {
          type   = "bind"
          source = "local/webserver_alert.yml"
          target = "/etc/prometheus/webserver_alert.yml"
          readonly = true
        }
        
        ports = ["prometheus_ui"]

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

alerting:
  alertmanagers:
  - consul_sd_configs:
    - server: '{{ env "NOMAD_IP_prometheus_ui" }}:8500'
      services: ['alertmanager']

rule_files:
  - "webserver_alert.yml"

scrape_configs:

  # alertmanager
  - job_name: 'alertmanager'

    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_prometheus_ui" }}:8500'
      services: ['alertmanager']

  # consul metrics
  - job_name: 'consul_metrics'
    scheme: 'http'

    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_prometheus_ui" }}:8500'
      services:
        - 'consul'
        
  # node-exporter metrics
  - job_name: 'node'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['{{ env "NOMAD_IP_prometheus_ui" }}:9100']

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

  # prometheus metrics
  - job_name: 'prometheus'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['{{ env "NOMAD_IP_prometheus_ui" }}:9090']
EOH
        destination = "local/prometheus.yml"
      }

      template {
        change_mode = "noop"
        data = <<EOH
---
groups:
- name: prometheus_alerts
  rules:
  - alert: Webserver down
    expr: absent(up{job="webserver"})
    for: 10s
    labels:
      severity: critical
    annotations:
      description: "Our webserver is down."
EOH
        destination = "local/webserver_alert.yml"
      }

      resources {
        cpu    = 100
        memory = 100
      }

      service {
        name = "prometheus"
        tags = ["urlprefix-/"]
        port = "prometheus_ui"
        check {
          name     = "prometheus_ui port alive"
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }

    }

  }

}