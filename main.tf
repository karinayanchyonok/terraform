terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.136"
    }
  }
}

provider "yandex" {
  cloud_id  = "b1gb7aiketk19vm3th5a"
  folder_id = "b1gg6budajcjd7gpjohb"
  service_account_key_file = "authorized_key_new.json"
}