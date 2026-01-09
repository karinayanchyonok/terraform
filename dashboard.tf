resource "yandex_monitoring_dashboard" "project" {
  name  = "team-project-dashboard-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  title = "Team Project - 3 VM Monitoring"
  
  # 1. CPU всех ВМ
  widgets {
    chart {
      title = "CPU Usage - All Servers"
      
      # Backend-0
      queries {
        target {
          query = "avg(cpu_usage{resource_id='fhm7qgtckhd5bdmjo2qp'})"
        }
      }
      
      # Backend-1  
      queries {
        target {
          query = "avg(cpu_usage{resource_id='fhmohqclvhi3u9kgrmtc'})"
        }
      }
      
      # PostgreSQL
      queries {
        target {
          query = "avg(cpu_usage{resource_id='fhm7a7aq6a6c46ggqj3h'})"
        }
      }
      
      visualization_settings {
        type = "VISUALIZATION_TYPE_LINE"  
      }
    }
    position {
      x = 0
      y = 0
      w = 24
      h = 8
    }
  }
  
  # 2. Memory Usage
  widgets {
    chart {
      title = "Memory Usage %"
      
      queries {
        target {
          query = "avg(memory_usage{resource_id='fhm7qgtckhd5bdmjo2qp'})"
        }
      }
      
      queries {
        target {
          query = "avg(memory_usage{resource_id='fhmohqclvhi3u9kgrmtc'})"
        }
      }
      
      queries {
        target {
          query = "avg(memory_usage{resource_id='fhm7a7aq6a6c46ggqj3h'})"
        }
      }
      
      visualization_settings {
        type = "VISUALIZATION_TYPE_LINE"  
      }
    }
    position {
      x = 0
      y = 8
      w = 12
      h = 8
    }
  }
  
  # 3. Disk Free Space %
  widgets {
    chart {
      title = "Disk Free Space %"
      
      queries {
        target {
          query = <<-EOT
            (
              avg(disk.free_bytes{resource_id="fhm7qgtckhd5bdmjo2qp"})
              /
              avg(disk.total_bytes{resource_id="fhm7qgtckhd5bdmjo2qp"})
              * 100
            )
          EOT
        }
      }
      
      queries {
        target {
          query = <<-EOT
            (
              avg(disk.free_bytes{resource_id="fhmohqclvhi3u9kgrmtc"})
              /
              avg(disk.total_bytes{resource_id="fhmohqclvhi3u9kgrmtc"})
              * 100
            )
          EOT
        }
      }
      
      queries {
        target {
          query = <<-EOT
            (
              avg(disk.free_bytes{resource_id="fhm7a7aq6a6c46ggqj3h"})
              /
              avg(disk.total_bytes{resource_id="fhm7a7aq6a6c46ggqj3h"})
              * 100
            )
          EOT
        }
      }
      
      visualization_settings {
        type = "VISUALIZATION_TYPE_LINE"  # ДОБАВИТЬ!
      }
    }
    position {
      x = 12
      y = 8
      w = 12
      h = 8
    }
  }
  
  # 4. Network Traffic
  widgets {
    chart {
      title = "Network Outbound Traffic"
      
      queries {
        target {
          query = "rate(network.out_bytes{resource_id='fhm7qgtckhd5bdmjo2qp'}[5m])"
        }
      }
      
      queries {
        target {
          query = "rate(network.out_bytes{resource_id='fhmohqclvhi3u9kgrmtc'}[5m])"
        }
      }
      
      queries {
        target {
          query = "rate(network.out_bytes{resource_id='fhm7a7aq6a6c46ggqj3h'}[5m])"
        }
      }
      
      visualization_settings {
        type = "VISUALIZATION_TYPE_LINE"  
      }
    }
    position {
      x = 0
      y = 16
      w = 24
      h = 8
    }
  }
  
  # 5. Информационный виджет (текстовый)
  widgets {
    text {
      text = <<-EOT
        Team Project Infrastructure Monitoring
        
        Servers:
        1. backend-0 (fhm7qgtckhd5bdmjo2qp) - Application server
        2. backend-1 (fhmohqclvhi3u9kgrmtc) - Application server  
        3. postgres (fhm7a7aq6a6c46ggqj3h) - Database server
        
        Dashboard created via Terraform
      EOT
    }
    position {
      x = 0
      y = 24
      w = 24
      h = 4
    }
  }
}