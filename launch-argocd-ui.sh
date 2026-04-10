#!/bin/bash
set -euo pipefail

echo "=== Launching Argo CD UI (secure password handling) ==="

# Safety check
if ! kubectl get ns argocd &>/dev/null; then
  echo "❌ Argo CD namespace not found. Make sure 'tofu apply' finished and pods are Ready."
  exit 1
fi

# Secure password retrieval – NEVER printed to shell
PASSWORD_FILE="$HOME/.kube/argocd-initial-admin.password"
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d > "$PASSWORD_FILE"

chmod 600 "$PASSWORD_FILE"

echo "✅ Admin credentials saved securely:"
echo "   Username : admin"
echo "   Password file : $PASSWORD_FILE  (chmod 600 – only you can read it)"
echo ""
echo "   After first login, change your password in the UI, then run:"
echo "   kubectl -n argocd delete secret argocd-initial-admin-secret"

# Start port-forward in background
echo "🔌 Starting port-forward (background) → https://localhost:8080"
kubectl port-forward svc/argocd-server -n argocd 8080:443 >/dev/null 2>&1 &
PF_PID=$!
sleep 3

# Try to open browser automatically
if command -v xdg-open >/dev/null; then
  xdg-open https://localhost:8080/ || true
elif command -v wslview >/dev/null; then
  wslview https://localhost:8080/ || true
else
  echo "🌐 Open this URL manually in your browser:"
  echo "   https://localhost:8080  (accept the self-signed certificate warning)"
fi

echo ""
echo "🎉 Argo CD UI is ready!"
echo "   To stop port-forward later:  kill $PF_PID   or   pkill -f 'port-forward svc/argocd-server'"
echo "   Monitor pods:               watch kubectl get pods -n argocd"