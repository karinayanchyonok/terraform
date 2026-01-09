# 1. Target Group - группа целей (ваши app серверы)
resource "yandex_alb_target_group" "app_target_group" {
  name        = "app-target-group"
  description = "Target group for backend application servers"

  dynamic "target" {
    for_each = yandex_compute_instance.app
    content {
      subnet_id  = target.value.network_interface[0].subnet_id
      ip_address = target.value.network_interface[0].ip_address
    }
  }
}

# 2. Backend Group - группа бэкендов
resource "yandex_alb_backend_group" "app_backend_group" {
  name        = "app-backend-group"
  description = "Backend group for application"

  http_backend {
    name             = "app-http-backend"
    weight           = 1
    port             = 8080  # Порт вашего Spring Boot приложения
    target_group_ids = [yandex_alb_target_group.app_target_group.id]

    # Health check - проверка здоровья
    healthcheck {
      timeout          = "10s"
      interval         = "2s"
      healthy_threshold   = 10
      unhealthy_threshold = 15
      
      http_healthcheck {
        path = "/actuator/health"  # Стандартный endpoint health check в Spring Boot
        # Если у вас другой endpoint, укажите его
        # path = "/health"
      }
    }

    # Настройки балансировки
    load_balancing_config {
      panic_threshold = 50  # Порог паники
    }

    # Таймауты
    tls {
      sni = "your-domain.com"  # Если используете HTTPS
    }
  }
}

# 3. HTTP Router - маршрутизатор
resource "yandex_alb_http_router" "app_router" {
  name        = "app-http-router"
  description = "HTTP router for application"
  
  # Можно добавить labels для меток
  labels = {
    project = "backend-app"
    env     = "production"
  }
}

# 4. Virtual Host - виртуальный хост
resource "yandex_alb_virtual_host" "app_virtual_host" {
  name           = "app-virtual-host"
  http_router_id = yandex_alb_http_router.app_router.id
  
  # authority - доменные имена, для которых работает этот виртуальный хост
  authority = ["*"]  # Принимаем все домены. Можно указать конкретные: ["app.example.com"]
  
  # Маршрут по умолчанию
  route {
    name = "main-route"
    
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.app_backend_group.id
        timeout          = "3s"
        
        # Можно настроить переписывание пути (если нужно)
        # prefix_rewrite = "/"
        
        # Можно добавить хост реврайт
        # host_rewrite = "internal-app"
      }
    }
  }
  
  # Дополнительные маршруты (пример)
  # route {
  #   name = "api-route"
  #   http_route {
  #     http_route_action {
  #       backend_group_id = yandex_alb_backend_group.app_backend_group.id
  #       timeout          = "3s"
  #       prefix_rewrite   = "/api"
  #     }
  #   }
  # }
}

# 5. Load Balancer - сам балансировщик
resource "yandex_alb_load_balancer" "app_balancer" {
  name               = "app-balancer"
  description        = "Application Load Balancer for backend"
  network_id         = yandex_vpc_network.main.id
  
  # Политика распределения
  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public.id
    }
    
    # Можно добавить другие зоны для отказоустойчивости
    # location {
    #   zone_id   = "ru-central1-b"
    #   subnet_id = yandex_vpc_subnet.public_b.id  # Нужна подсеть в зоне B
    # }
  }

  # Security Groups (рекомендуется добавить)
  # security_group_ids = [yandex_vpc_security_group.alb_sg.id]

  # Listener - обработчик входящих подключений
  listener {
    name = "http-listener"
    
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    
    http {
      handler {
        http_router_id = yandex_alb_http_router.app_router.id
        
        # Можно настроить HTTP/2
        # http2_options {}
      }
      
      # Можно добавить редирект с HTTP на HTTPS
      # redirects {
      #   http_to_https = true
      # }
    }
  }
  
  # HTTPS Listener (опционально, если есть SSL сертификат)
  # listener {
  #   name = "https-listener"
  #   
  #   endpoint {
  #     address {
  #       external_ipv4_address {}
  #     }
  #     ports = [443]
  #   }
  #   
  #   tls {
  #     default_handler {
  #       http_handler {
  #         http_router_id = yandex_alb_http_router.app_router.id
  #       }
  #       certificate_ids = ["your-certificate-id"]
  #     }
  #   }
  # }

  # Логирование (опционально)
  # log_options {
  #  log_group_id = yandex_logging_group.alb_logs.id  # Нужно создать Log Group
  #}
}