job "weather-sense-monitor" {

  datacenters = ["dc1"]

  type        = "service"

  group "iot" {

    count = 1
    
    // service {
    //   name = "node-exporter"
    //   tags = []
    //   port = "exporter"
    //   check {
    //     name     = "alive"
    //     type     = "tcp"
    //     interval = "10s"
    //     timeout  = "2s"
    //   }
    // }

    task "weather-sense-monitor" {
      
      driver = "raw_exec"

      config {
        command = "SDL_Pi_WeatherSense/start.sh"
      }

      artifact {
        source = "git::https://github.com/greenthegarden/SDL_Pi_WeatherSense.git"
        destination = "local/SDL_Pi_WeatherSense"
      }

      resources {
        cpu    = 200
        memory = 64
        cores = 2
      }
    }
  }
}
