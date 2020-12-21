resource "aws_route53_zone" "private" {
  name = "ceph.internal"

  vpc {
    vpc_id = aws_vpc.ceph.id
  }
}


resource "aws_route53_record" "mon" {
  zone_id = aws_route53_zone.private.zone_id
  count   = var.mon_count
  name    = "mon${count.index}.ceph.internal"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.mon.*.private_ip, count.index)]
}



resource "aws_route53_record" "osd" {
  zone_id = aws_route53_zone.private.zone_id
  count   = var.osd_count
  name    = "osd${count.index}.ceph.internal"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.osd.*.private_ip, count.index)]
}

