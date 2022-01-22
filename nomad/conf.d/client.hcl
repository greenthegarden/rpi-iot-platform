client {
  enabled = true
  meta {
  }
  network_interface = "eth0"
  server_join {
    retry_join = [
      "127.0.0.1"
    ]
    retry_max = 3
    retry_interval = "15s"
  }
  options {
    "docker.volumes.enabled" = "true"
  }
  template {
    disable_file_sandbox = true
  }
}

// plugin "docker" {
//   config {
//     // allow_privileged = true
//     // allow_caps = [ "ALL" ]
//     volumes {
//       enabled      = true
//     }
//   }
// }
