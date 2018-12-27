locals {
  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.prasad-kube.endpoint}
    certificate-authority-data: ${aws_eks_cluster.prasad-kube.certificate_authority.0.data}
  name: arn:aws:eks:us-east-1:918606473678:cluster/${var.cluster-name}
contexts:
- context: 
    cluster: arn:aws:eks:us-east-1:918606473678:cluster/${var.cluster-name}
    user: arn:aws:eks:us-east-1:918606473678:cluster/${var.cluster-name}
  name: arn:aws:eks:us-east-1:918606473678:cluster/${var.cluster-name}
current-context: arn:aws:eks:us-east-1:918606473678:cluster/${var.cluster-name}
kind: Config
preferences: {}
users:
- name: arn:aws:eks:us-east-1:918606473678:cluster/${var.cluster-name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster-name}"
KUBECONFIG
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}
