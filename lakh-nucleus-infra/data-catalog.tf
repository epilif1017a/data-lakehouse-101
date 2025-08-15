resource "docker_volume" "unitycatalog_conf" {
  name = "unitycatalog_conf"
}

resource "docker_volume" "unitycatalog_data" {
  name = "unitycatalog_data"
}

resource "docker_image" "uc_server" {
  name         = "unitycatalog/unitycatalog:latest"
  keep_locally = true
}

resource "docker_image" "uc_ui" {
  name         = "unitycatalog/unitycatalog-ui:main"
  keep_locally = true
}

resource "docker_container" "uc_server" {
  name  = "uc-server" # do not change as unity catalog ui as it configured as PROXY_HOST build arg
  image = docker_image.uc_server.image_id

  ports {
    internal = 8080
    external = 8080
  }

  volumes {
    volume_name    = docker_volume.unitycatalog_conf.name
    container_path = "/opt/unitycatalog/etc/conf"
  }
  volumes {
    volume_name    = docker_volume.unitycatalog_data.name
    container_path = "/opt/unitycatalog/etc/data"
  }

  # All containers are added to the same network for inter-service communication.
  # The alias is crucial for the Spark container to resolve 'unity-catalog-server'.
  networks_advanced {
    name    = docker_network.lakh_net.name
    aliases = ["server", "unity-catalog-server"]
  }
}

resource "docker_container" "uc_ui" {
  name  = "uc-ui"
  image = docker_image.uc_ui.image_id

  ports {
    internal = 3000
    external = 3000
  }

  networks_advanced {
    name = docker_network.lakh_net.name
  }

  depends_on = [
    docker_container.uc_server
  ]
}