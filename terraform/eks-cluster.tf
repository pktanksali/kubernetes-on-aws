resource "aws_eks_cluster" "prasad-kube" {
  name            = "${var.cluster-name}"
  role_arn        = "${aws_iam_role.prasad-kube-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.prasad-kube-cluster.id}"]
    subnet_ids         = ["${aws_subnet.prasad-kube.*.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.prasad-kube-cluster-policy",
    "aws_iam_role_policy_attachment.prasad-kube-service-policy",
  ]
}
