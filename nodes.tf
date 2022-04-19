resource "aws_iam_role" "node" {
    name = "${var.prefix}-${var.cluster_name}-role-node"
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

// Cria policies para o role do node poder acessar o EKS como um node
resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.node.name
}

// Cria policy para efetuar a comunicação entre os nodes
resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.node.name
}

// Cria policy para permitir a leitura ao Caontainer registry para baixar as imagens
resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.node.name
}

resource "aws_eks_node_group" "node-1" {
    cluster_name = aws_eks_cluster.cluster.name
    node_group_name = "node-1"
    node_role_arn = aws_iam_role.node.arn
    subnet_ids = aws_subnet.subnets[*].id

    scaling_config {
        desired_size = var.desired_size
        max_size = var.max_size
        min_size = var.min_size
    }
    instance_types = ["t3.micro"]
    depends_on = [
      aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
        aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    ]
}

resource "aws_eks_node_group" "node-2" {
    cluster_name = aws_eks_cluster.cluster.name
    node_group_name = "node-2"
    node_role_arn = aws_iam_role.node.arn
    subnet_ids = aws_subnet.subnets[*].id

    scaling_config {
        desired_size = var.desired_size
        max_size = var.max_size
        min_size = var.min_size
    }
    instance_types = ["t3.micro"]
    depends_on = [
      aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
        aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    ]
}


