resource "aws_security_group" "new_security_group" {
  vpc_id = aws_vpc.new_vpc.id
  tags = {
    Name = "${var.prefix}-sg"
  }
  egress {                          # Outbound rules
    from_port       = 0             #todas as portas liberadas
    to_port         = 0             #todas as portas liberadas
    protocol        = "-1"          #todos liberados
    cidr_blocks     = ["0.0.0.0/0"] #liberado de todas as redes
    prefix_list_ids = []
  }
}

resource "aws_iam_role" "cluster" {
  name = "${var.prefix}-${var.cluster_name}-role"
  assume_role_policy = <<POLICY
{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
                    "Service": "eks.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    POLICY
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
    role = aws_iam_role.cluster.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
    role = aws_iam_role.cluster.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_cloudwatch_log_group" "log" {
    name = "/aws/eks/${var.prefix}-${var.cluster_name}/cluester"
    retention_in_days = var.retention_days
}

resource "aws_eks_cluster" "cluster" {
    name = "${var.prefix}-${var.cluster_name}"
    role_arn = aws_iam_role.cluster.arn
    enabled_cluster_log_types = ["api", "audit"]

    vpc_config {
        subnet_ids = aws_subnet.subnets[*].id
        security_group_ids = [aws_security_group.new_security_group.id]
    }
    depends_on = [
      aws_cloudwatch_log_group.log,
      aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController,
      aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    ]
}