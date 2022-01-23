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
  host_volume "pihole-pihole" {
    path      = "/mnt/storage/nomad/data/pihole/pihole"
    read_only = false
  }
  host_volume "pihole-dnsmasq" {
    path      = "/mnt/storage/nomad/data/pihole/dnsmasq.d"
    read_only = false
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
