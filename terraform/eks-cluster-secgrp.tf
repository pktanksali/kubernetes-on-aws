resource "aws_security_group" "prasad-kube-cluster" {
  name        = "eks-cluster-secgrp"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.prasad-kube.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "prasad-kube-secgrp"
  }
}

resource "aws_security_group_rule" "prasad-kube-cluster-ingress" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.prasad-kube-cluster.id}"
  to_port           = 443
  type              = "ingress"
}
