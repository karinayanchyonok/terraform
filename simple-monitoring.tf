# simple-monitoring.tf
resource "yandex_monitoring_dashboard" "simple" {
  name  = "simple-monitoring-${formatdate("YYYYMMDD", timestamp())}"
  title = "Simple Monitoring Dashboard"
  
  # Только ОДИН простой виджет
  widgets {
    chart {
      title = "CPU Usage"
      
      queries {
        target {
          query = "cpu_usage"
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
}