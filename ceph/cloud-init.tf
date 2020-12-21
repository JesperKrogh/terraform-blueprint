variable "filename" {
  default = "cloud-config.cfg"
}


data "template_file" "osd-ci" {
  count = var.osd_count
  template = <<EOF
#cloud-config
hostname: $${hostname}
package_update: true
package_upgrade: false
bootcmd: 
  - "echo 'append domain-name \" ceph.internal\";' >> /etc/dhcp/dhclient.conf"
  - "sed -i -E 's/(search.+?)$/\\1 ceph.internal/' /etc/resolv.conf"
output:
  all: '| tee -a /var/log/cloud-init-output.log'
EOF

  vars = {
    hostname = "osd${count.index}"
  }
}

data "template_cloudinit_config" "osd-ci" {
  gzip          = false
  base64_encode = false
  count = var.osd_count

  part {
    filename     = var.filename
    content_type = "text/cloud-config"
    content      = element(data.template_file.osd-ci.*.rendered,count.index)
  }
}

data "template_file" "mon-ci" {
  count = var.mon_count
  template = <<EOF
#cloud-config
hostname: $${hostname}
package_update: true
package_upgrade: false
bootcmd: 
  - "echo 'append domain-name \" ceph.internal\";' >> /etc/dhcp/dhclient.conf"
  - "sed -i -E 's/(search.+?)$/\\1 ceph.internal/' /etc/resolv.conf"
output:
  all: '| tee -a /var/log/cloud-init-output.log'
EOF

  vars = {
    hostname = "mon${count.index}"
  }
}

data "template_cloudinit_config" "mon-ci" {
  gzip          = false
  base64_encode = false
  count = var.mon_count

  part {
    filename     = var.filename
    content_type = "text/cloud-config"
    content      = element(data.template_file.mon-ci.*.rendered,count.index)
  }
}
