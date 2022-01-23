job "pihole" {

  region = "global"

  datacenters = ["dc1"]
  
  type        = "service"

  group "pihole" {

    count = 1

    network {
      mode = "bridge"
      // port "dhcp" {
	    //   static       = 67
      //   to           = 67
      // }
      port "dns" {
        static = 53
      }
      port "http" {
        static = 80
        to = 80
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    service {
      name = "pihole"
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
        "traefik.http.routers.pihole.rule=PathPrefix(`/pihole`)",
      ]
    }
      
    task "pihole" {

      env = {
        "TZ"           = "Australia/Adelaide"
        "DNS1"         = "192.168.1.1"
        "DNS2"         = "no"
        "INTERFACE"    = "eth0"
        "VIRTUAL_HOST" = "insert_your_virtual_host_fqdn"
        "ServerIP"     = "192.168.1.107"
      }

      driver = "docker"

      config {
        image = "pihole/pihole:latest"
       
        dns_servers = [
          "127.0.0.1",
          "1.1.1.1",
        ]
        
        mount {
          type     = "bind"
          target   = "/etc/pihole"
          source   = "/mnt/storage/nomad/data/pihole/pihole"
          readonly = false
        }

        mount {
          type     = "bind"
          target   = "/etc/dnsmasq.d"
          source   = "/mnt/storage/nomad/pihole/dnsmasq.d"
          readonly = false
        }
        
        ports = ["dns", "http"]
        
      }

      resources {
        cpu    = 100
        memory = 128
      }

    }

  }

}