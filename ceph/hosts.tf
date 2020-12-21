variable "osd_count" {
  type = number
}
variable "mon_count" {
  type = number
}

variable "osd_instance_type" {
  type = string
}
variable "mon_instance_type" {
  type = string
}



resource "aws_instance" "management-host" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
  subnet_id = aws_subnet.cephadm.id
  key_name = aws_key_pair.terraformcluster.key_name
  associate_public_ip_address = true
  user_data = "#!/bin/bash\nsed -i 's/compute.internal/compute.internal ceph.internal/' /etc/resolv.conf\ncp /etc/resolv.conf /tmp; rm /etc/resolv.conf; mv /tmp/resolv.conf /etc\necho 'management' > /etc/hostname\nhostname -F /etc/hostname\n"
  tags = {
        Name = "Ceph Management Host"
  }
}

resource "aws_instance" "mon" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.mon_instance_type
  count = var.mon_count
  vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
  subnet_id = aws_subnet.ceph.id
  key_name = aws_key_pair.terraformcluster.key_name
  associate_public_ip_address = false
  tags = {
        Name = "Ceph Monitor ${count.index}"
  }
  user_data = element(data.template_file.mon-ci.*.rendered,count.index)
}

resource "aws_instance" "osd" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.osd_instance_type
  count = var.osd_count
  vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
  subnet_id = aws_subnet.ceph.id
  key_name = aws_key_pair.terraformcluster.key_name
  tags = {
        Name = "Ceph OSD ${count.index}"
  }
  associate_public_ip_address = false
  user_data = element(data.template_file.osd-ci.*.rendered,count.index)
}


