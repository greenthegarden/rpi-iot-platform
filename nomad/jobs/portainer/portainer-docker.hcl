# Source for Traefik config https://stackoverflow.com/questions/41637806/routing-paths-with-traefik

job "portainer" {

  region = "global"

  datacenters = ["dc1"]
  
  type        = "service"

  group "portainer" {

    count = 1

    network {
      port "http" {
        static = 9443
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    service {
      name = "portainer"
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
        "traefik.http.routers.portainer.rule=PathPrefix(`/portainer`)",
        "traefik.http.routers.portainer.middlewares=portainer-redirectregex, portainer-replacepathregex",
        "traefik.http.middlewares.portainer-replacepathregex.replacepathregex.regex=^/portainer/(.*)",
        "traefik.http.middlewares.portainer-replacepathregex.replacepathregex.replacement=/$$1",
        "traefik.http.middlewares.portainer-redirectregex.redirectregex.regex=^(.*)/portainer$$",
        "traefik.http.middlewares.portainer-redirectregex.redirectregex.replacement=$$1/portainer/",
      ]
    }

        // "traefik.http.middlewares.portainer-stripprefix.stripprefix.prefixes=/portainer",
        // "traefik.http.middlewares.portainer-stripprefix.stripprefix.forceSlash=false",
        // "traefik.http.routers.portainer.middlewares=portainer-stripprefix",

        // // "traefik.http.routers.portainer-secure.rule=Host(`your-domain.com`) && PathPrefix(`/portainer`)"


    task "portainer" {

      driver = "docker"

      config {
        image = "portainer/portainer-ce:linux-arm"
       
      mount {
          type   = "bind"
          source = "/var/run/docker.sock"
          target = "/var/run/docker.sock"
          readonly = true
        }
        
        ports = ["http"]
      }

      resources {
        cpu    = 100
        memory = 100
      }

    }

  }

}