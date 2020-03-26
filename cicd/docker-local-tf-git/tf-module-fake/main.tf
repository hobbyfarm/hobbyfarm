variable "name" {}
variable "access_code" {
  default = ""
}
variable "course" {
  default = "course:none"
}
variable "image" {
  default = "ubuntu-1804-lts"
}
variable "disk" {
  default = "10"
}
variable "public_key" {}
variable "ssh_user" {
  default = "ubuntu"
}

resource "null_resource" "instance" {

  provisioner "local-exec" {
    command = <<EOT
      chmod 600 "${path.module}/id_hf_tf"
      ssh \
        -i "${path.module}/id_hf_tf" \
        -o StrictHostKeyChecking=no \
        ubuntu@sshd "
          echo "${chomp(var.public_key)} ${chomp(var.name)}" \
          >> /home/ubuntu/.ssh/authorized_keys
        "
EOT
    interpreter = ["sh", "-c"]
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = <<EOT
      chmod 600 "${path.module}/id_hf_tf"
      ssh \
        -i "${path.module}/id_hf_tf" \
        -o StrictHostKeyChecking=no \
        ubuntu@sshd '
          grep \
            -vF "${chomp(var.public_key)} ${chomp(var.name)}" \
            /home/ubuntu/.ssh/authorized_keys \
            > /home/ubuntu/.ssh/authorized_keys2
          mv \
            /home/ubuntu/.ssh/authorized_keys2 \
            /home/ubuntu/.ssh/authorized_keys
        '
EOT
    interpreter = ["sh", "-c"]
  }

}

output "private_ip" {
  value = "1.2.3.4"
}

output "public_ip" {
  value = "1.2.3.4"
}

output "hostname" {
  value = "sshd"
}
