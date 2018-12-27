data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

data "aws_region" "current" {}

locals {
  prasad-kube-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.prasad-kube.endpoint}' --b64-cluster-ca  '${aws_eks_cluster.prasad-kube.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA
}

resource "aws_launch_configuration" "prasad-kube" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.prasad-kube-node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "t2.small"
  name_prefix                 = "eks-worker-node"
  security_groups             = ["${aws_security_group.prasad-kube-node.id}"]
  user_data_base64            = "${base64encode(local.prasad-kube-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "prasad-kube" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.prasad-kube.id}"
  max_size             = 2
  min_size             = 1
  name                 = "eks-node-autoscaling"
  vpc_zone_identifier  = ["${aws_subnet.prasad-kube.*.id}"]

  tag {
    key                 = "Name"
    value               = "eks-node-autoscaling	"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
