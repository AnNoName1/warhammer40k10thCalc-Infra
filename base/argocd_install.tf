resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  version    = "7.7.0" # Актуальная версия на начало 2026

  cleanup_on_fail = true # Удалять созданные ресурсы, если установка не удалась
  force_update    = true # Позволяет принудительно обновлять ресурсы
}