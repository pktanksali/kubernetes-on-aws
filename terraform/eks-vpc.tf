data "aws_availability_zones" "available" {}

resource "aws_vpc" "prasad-kube" {
  cidr_block = "10.0.0.0/16"
  tags = "${
    map(
     "Name", "eks-vpc",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "prasad-kube" {
  count = 2
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.prasad-kube.id}"
  tags = "${
    map(
     "Name", "eks-subnet",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "prasad-kube" {
  vpc_id = "${aws_vpc.prasad-kube.id}"
  tags {
    Name = "eks-gateway"
  }
}

resource "aws_route_table" "prasad-kube" {
  vpc_id = "${aws_vpc.prasad-kube.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.prasad-kube.id}"
  }
}

resource "aws_route_table_association" "prasad-kube" {
  count = 2
  subnet_id      = "${aws_subnet.prasad-kube.*.id[count.index]}"
  route_table_id = "${aws_route_table.prasad-kube.id}"
}
