job "weather-sense-monitor" {

  datacenters = ["dc1"]

  type        = "service"

  group "iot" {

    count = 1
    
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
      }
    }
  }
}
