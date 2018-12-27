resource "aws_security_group" "prasad-kube-node" {
  name        = "eks-node-secgrp"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.prasad-kube.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "eks-node-secgrp",
     "kubernetes.io/cluster/${var.cluster-name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "prasad-kube-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.prasad-kube-node.id}"
  source_security_group_id = "${aws_security_group.prasad-kube-node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "prasad-kube-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.prasad-kube-node.id}"
  source_security_group_id = "${aws_security_group.prasad-kube-cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "prasad-kube-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.prasad-kube-cluster.id}"
  source_security_group_id = "${aws_security_group.prasad-kube-node.id}"
  to_port                  = 443
  type                     = "ingress"
}
