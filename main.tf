# -------------------------------------------------------------------------------------------------
# VPC
# -------------------------------------------------------------------------------------------------
resource "aws_vpc" "this" {
  cidr_block                       = var.cidr
  assign_generated_ipv6_cidr_block = true

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags,
  )
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = var.name
      "Type" = "public"
    },
    var.tags,
  )
}

resource "aws_subnet" "public" {
  count = 2

  vpc_id                          = aws_vpc.this.id
  cidr_block                      = cidrsubnet(var.cidr, 8, count.index)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, count.index)
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = true

  availability_zone = data.aws_availability_zones.available.names[count.index]

  # If AWS adds another availability zone, this will not have effect on the already picked subnets.
  lifecycle {
    ignore_changes = [availability_zone]
  }

  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.name,
        count.index,
      )
    },
    var.tags,
  )
}

resource "aws_route_table_association" "this" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags,
  )
}

resource "aws_security_group" "this" {
  name        = "${var.name}-albredirect"
  description = "Allow inbound 80/443 traffic alb redirect"
  vpc_id      = aws_vpc.this.id

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------------------------------------------------------------------------------
# LB
# -------------------------------------------------------------------------------------------------
resource "aws_lb" "this" {
  load_balancer_type               = "application"
  name                             = var.name
  security_groups                  = [aws_security_group.this.id]
  subnets                          = aws_subnet.public.*.id
  enable_cross_zone_load_balancing = false
  enable_deletion_protection       = false
  enable_http2                     = true
  ip_address_type                  = var.lb_ip_address_type
  tags = merge(
    var.tags,
    {
      "Name" = var.name
    },
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = var.response_message_body
      status_code  = var.response_code
    }
  }
}

resource "aws_lb_listener" "https" {
  count = var.https_enabled ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = var.response_message_body
      status_code  = var.response_code
    }
  }
}

resource "aws_lb_listener_certificate" "https" {
  listener_arn    = join("", aws_lb_listener.https.*.arn)
  certificate_arn = var.extra_ssl_certs[count.index]
  count           = var.extra_ssl_certs_count
}

locals {
  listener_types = slice(["HTTP", "HTTPS"], 0, var.https_enabled ? 2 : 1)

  rules = flatten([
    for rule in var.redirect_rules : [
      for listener_type in local.listener_types : {
        listener_type = listener_type,
        rule          = rule,
      }
  ]])
}

resource "aws_lb_listener_rule" "this" {
  # If condition makes sure we not forward from HTTPS to HTTP, as this is not allowed by the AWS ALB
  for_each = { for rule in local.rules :
    "${rule.listener_type}://${rule.rule.host_match}${rule.rule.path_match}" => merge(
      rule.rule,
      { "listener_type" = rule.listener_type }
  ) if lookup(rule.rule, "disabled_for", "") != rule.listener_type }

  listener_arn = each.value.listener_type == "HTTP" ? aws_lb_listener.http.arn : join("", aws_lb_listener.https.*.arn)

  action {
    type = "redirect"

    redirect {
      port        = lookup(each.value, "redirect_port", "#{port}")
      protocol    = lookup(each.value, "redirect_protocol", "#{protocol}")
      host        = lookup(each.value, "redirect_host", "#{host}")
      query       = lookup(each.value, "redirect_query", null)
      path        = lookup(each.value, "redirect_path", null)
      status_code = lookup(each.value, "redirect_status_code", "HTTP_302")
    }
  }

  dynamic condition {
    for_each = lookup(each.value, "path_match", "*") != "*" ? [1] : []
    content {
      path_pattern {
        values = [lookup(each.value, "path_match", "*")]
      }
    }
  }

  dynamic condition {
    for_each = lookup(each.value, "host_match", "*") != "*" ? [1] : []
    content {
      host_header {
        values = [lookup(each.value, "host_match", "*")]
      }
    }
  }
}
