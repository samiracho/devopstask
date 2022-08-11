resource "aws_key_pair" "devopstask_instance_keypair" {
  key_name        = "${var.environment}-devopstask-keypair"
  public_key      = trimspace(tls_private_key.devopstask_instance_privatekey.public_key_openssh)
}

resource "tls_private_key" "devopstask_instance_privatekey" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "devopstask_privatekey" {
  content = tls_private_key.devopstask_instance_privatekey.private_key_pem
  filename  = "${path.module}/../${var.environment}-devopstask-keypair.pem"
  file_permission = "0600"
}

resource "aws_security_group" "devopstask_instance_sg" {
  vpc_id      = aws_vpc.devopstask_vpc.id
  description = "Allow ssh, ports for exposing api, jenkins and outcoming connections"

  # ssh
  ingress {
    from_port = 22
    protocol  = "TCP"
    to_port   = 22
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  # ports for develop/staging/production 
  ingress {
    from_port = 9000
    protocol  = "TCP"
    to_port   = 9002
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  # port for jenkins 
  ingress {
    from_port = 8443
    protocol  = "TCP"
    to_port   = 8443
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  # allow outcoming connections
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-devopstask-sg"
  }
}

#aws instance creation
resource "aws_instance" "devopstask_instance" {
  ami                         = var.instance_ami_id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.devopstask_instance_sg.id]
  key_name                    = aws_key_pair.devopstask_instance_keypair.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.devopstask_public_subnet.id

  tags = {
    Name = "${var.environment}-devopstask"
  }
}

# Run ansible playbook on EC2 instance
resource "null_resource" "ansible_playbook" {
  depends_on = [aws_instance.devopstask_instance]
  provisioner "local-exec" {
    working_dir = "${path.module}/../ansible/"

    command = <<-EOF
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu \
      --private-key ${local_file.devopstask_privatekey.filename} \
      --extra-vars "jenkins_public_ip=${aws_instance.devopstask_instance.public_ip}" \
      -i '${aws_instance.devopstask_instance.public_dns},' playbook.yaml
    EOF
  
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}