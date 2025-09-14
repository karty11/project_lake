output "iam_role_arn" {
  value = aws_iam_role.external_secrets_irsa.arn
}

output "oidc_provider" {
  value = aws_iam_openid_connect_provider.eks.url
}

output "cluster_name_debug" {
  value = var.cluster_name
}

output "aws_region_debug" {
  value = var.aws_region
}

output "aws_identity_debug" {
  value = data.aws_caller_identity.current.arn
}

output "role_name" {
  value = data.aws_iam_role.external_secrets_role.name
}

output "role_arn" {
  value = data.aws_iam_role.external_secrets_role.arn
}

output "datalake_policy_arn" {
  value = aws_iam_policy.datalake_policy.arn
}
