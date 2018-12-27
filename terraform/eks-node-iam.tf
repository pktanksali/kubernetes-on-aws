resource "aws_iam_role" "prasad-kube-node" {
  name = "eks-worker-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "prasad-kube-worker-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.prasad-kube-node.name}"
}

resource "aws_iam_role_policy_attachment" "prasad-kube-node-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.prasad-kube-node.name}"
}

resource "aws_iam_role_policy_attachment" "prasad-kube-container-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.prasad-kube-node.name}"
}

resource "aws_iam_instance_profile" "prasad-kube-node" {
  name = "eks-node-profile"
  role = "${aws_iam_role.prasad-kube-node.name}"
}
