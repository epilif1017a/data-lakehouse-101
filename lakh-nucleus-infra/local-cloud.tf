resource "docker_image" "localstack" {
  name         = "localstack/localstack:latest"
  keep_locally = true
}

resource "docker_network" "lakh_net" {
  name = "lakh-net"
}

resource "docker_volume" "localstack_volume" {
  name = "localstack"
}

# LocalStack container, equivalent to the 'localstack' service.
resource "docker_container" "localstack" {
  name  = "localstack"
  image = docker_image.localstack.image_id

  ports {
    internal = 4566
    external = 4566
  }

  # Dynamically creates port mappings for the 4510-4559 range.
  dynamic "ports" {
    for_each = range(4510, 4560) # Note: range() is exclusive of the end value.
    content {
      internal = ports.value
      external = ports.value
    }
  }

  env = [
    "SERVICES=s3,ec2",
    "DEBUG=1",
    "GATEWAY_LISTEN=0.0.0.0:4566",
    "MAIN_CONTAINER_NAME=localstack"
  ]

  volumes {
    volume_name    = docker_volume.localstack_volume.name
    container_path = "/var/lib/localstack"
  }
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  networks_advanced {
    name = docker_network.lakh_net.name
  }
}

resource "time_sleep" "wait_30_seconds" {
  # make sure that localstack container is ready
  create_duration = "30s"

  depends_on = [
    docker_container.localstack
  ]
}

module "vpc" {
  source = "../lakh-nucleus-iac-modules/vpc"

  depends_on = [
    time_sleep.wait_30_seconds
  ]
}

module "bucket" {
  source      = "../lakh-nucleus-iac-modules/s3-bucket"
  bucket_name = "beaninpt-lakh-nucleus"

  depends_on = [
    module.vpc
  ]
}