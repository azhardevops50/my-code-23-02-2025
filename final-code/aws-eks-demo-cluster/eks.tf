resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = [
      aws_subnet.public_subnet_1.id,
      aws_subnet.public_subnet_2.id,
      aws_subnet.private_subnet_1.id,
      aws_subnet.private_subnet_2.id,
    ]
    security_group_ids = [aws_security_group.kubernetes_master.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_AmazonEKSVPCResourceController
  ]

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_iam_role" "cluster" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

resource "aws_eks_node_group" "ng-private" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "my-eks-nodegroup"
  node_role_arn   = aws_iam_role.ng-role.arn

  version = var.cluster_version
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id,
  ]
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = var.instance_types
  capacity_type  = "ON_DEMAND"

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
  ]
}

resource "terraform_data" "kubectl" {

  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_name}"
  }

  depends_on = [aws_eks_cluster.eks-cluster,
    aws_eks_node_group.ng-private,
  ]
}

