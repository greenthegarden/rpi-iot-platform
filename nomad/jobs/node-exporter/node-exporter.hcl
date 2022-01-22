# Source: https://github.com/angrycub/nomad_example_jobs/blob/main/applications/prometheus/node-exporter.nomad
# The Prometheus Node Exporter needs access to the proc filesystem which is not
# mounted into the exec jail, so it requires the raw_exec driver to run.

job "node-exporter" {

  datacenters = ["dc1"]

  type        = "system"

  group "system" {

    count = 1
    
    network {
      mode = "bridge"
      port "exporter" {
        static = 9100 
      }
    }

    service {
      name = "node-exporter"
      tags = []
      port = "exporter"
      check {
        name     = "alive"
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "node-exporter" {
      driver = "raw_exec"

      config {
        command = "local/node_exporter-1.3.1.linux-armv7/node_exporter"
        args = [
          "--web.listen-address=:${NOMAD_PORT_exporter}"
        ]
      }

      artifact {
        source = "https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-armv7.tar.gz"
        destination = "local"
        options { 
          checksum = "sha256:24c2abf3ce906188b9725c5235424e984b263d4efddb988b59ed7d3c0e695e8f"
        }
      }

      resources {
        // MHz
        cpu    = 500
        // MBytes
        memory = 50
      }
    }
  }
}