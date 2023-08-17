job "rtl433" {

  datacenters = ["dc1"]

  type        = "service"

  group "iot" {

    count = 1
    
    task "rtl433" {
      
      driver = "raw_exec"

      config {
        command = "/usr/local/bin/rtl_433"
        args = ["-F", "json"]
//        args = ["-F", "json", "-R", "146", "-R", "147", "-R", "148", "-R", "150", "-R", "151", "-R", "152", "-R", "153", "-R", "154", "-R", "155"]
      }

      resources {
        cpu    = 200
        memory = 64
      }
    }
  }
}
