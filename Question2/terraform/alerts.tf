resource "aws_cloudwatch_metric_alarm" "foobar" {
  alarm_name                = "terraform-test-foobar"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  threshold                 = "50"
  alarm_description         = "Request error rate has exceeded 100"
  insufficient_data_actions = []

  metric_query {
    id          = "e1"
    expression  = "m1*1"
    label       = "Error Rate"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "HTTPCode_ELB_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = "120"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        LoadBalancer = "app/web"
      }
    }
  }
}
resource "aws_cloudwatch_metric_alarm" "extra" {
  alarm_name                = "terraform-test-foobar"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  threshold                 = "100"
  alarm_description         = "Request error rate has exceeded 100"
  insufficient_data_actions = []

  metric_query {
    id          = "e1"
    expression  = "m1*1"
    label       = "Error Rate"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "HTTPCode_ELB_4XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = "3600"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        LoadBalancer = "app/web"
      }
    }
  }
}
resource "aws_cloudwatch_metric_alarm" "checktxt" {
  alarm_name                = "terraform-test-foobar"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  threshold                 = "0"
  alarm_description         = "Request error rate has exceeded 100"
  insufficient_data_actions = []

  metric_query {
    id          = "e1"
    expression  = "m1*1"
    label       = "Error Rate"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "HTTPCode_ELB_2XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        LoadBalancer = "app/web"
      }
    }
  }
}