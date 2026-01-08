resource "yandex_vpc_network" "main" {
  name = "project-network"
}

resource "yandex_vpc_subnet" "public" {
  name           = "project-public-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}
