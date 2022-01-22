job "emqx" {

  region = "global"

  datacenters = ["dc1"]

  type = "service"
  
  group "emqx" {
  
    count = 1

    restart {
      attempts = 5
      delay    = "30s"
    }
  
    task "emqx" {
  
      driver = "raw_exec"
               
      env = {
        "WAIT_FOR_ERLANG" = "60"
        "EMQX_OS_MON__CPU_CHECK_INTERVAL" = "2h"
        "EMQX_OS_MON__MEM_CHECK_INTERVAL" = "2h"
      }

        // "EMQX_NODE__NAME" = "emqx@rtl433.localdomain"
        // EMQX_BRIDGE__MQTT__HOMEASSISTANT__ADDRESS = ""

      config {
        command = "local/emqx/bin/emqx"
        args    = ["console"]
      }
  
      artifact {
        source = "https://www.emqx.com/en/downloads/edge/v4.3.11/emqx-edge-raspbian10-4.3.11-arm.zip"
        destination = "local"
        options {
          checksum = "sha256:8675c9d2659bcee4cf13dc32e70abc7ef4099a8532be2fb7cfd0b50ded86b151"
        }      
      }

      // network {
      //     port "http" {}

      // service {
      //   name = "emqx-ui"
      //   port = "http"
      // }

      resources {
        // Raspberry Pi 3 Model B
        // https://www.raspberrypi.com/products/raspberry-pi-3-model-b/
        // cpu in MHz - spec Quad Core 1.2GHz
        // cpu = 1200
        // core - spec Quad core
        cores = 4
        // memory in MB - spec 1GB RAM
        memory = 512
      }

    }
  
  }

}