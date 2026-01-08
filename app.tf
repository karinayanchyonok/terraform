resource "yandex_compute_instance" "app" {
  name        = "backend"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8qa5pcd0l7123dpvhc"
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    user-data = <<-EOF
      #cloud-config
      packages:
        - docker.io

      write_files:
        - path: /usr/local/bin/start-app.sh
          permissions: '0755'
          content: |
            #!/bin/bash
            set -xe
            systemctl enable docker
            systemctl start docker

            docker rm -f project-app || true

            docker run -d \
              --name project-app \
              -p 8080:8080 \
              -e SPRING_DATASOURCE_URL="jdbc:postgresql://${yandex_compute_instance.postgres.network_interface.0.ip_address}:5432/project" \
              -e SPRING_DATASOURCE_USERNAME=project \
              -e SPRING_DATASOURCE_PASSWORD=project \
              -e SPRING_JPA_HIBERNATE_DDL_AUTO=update \
              payk96/project-pavlov:latest

      runcmd:
        - [ /usr/local/bin/start-app.sh ]
    EOF

    ssh-keys = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOk2TiSsrmpBtgyXLiaGxDcZLVMpBNxrjmJFewGoJ7Hj pepethefrog27@mail.ru"
  }
}
