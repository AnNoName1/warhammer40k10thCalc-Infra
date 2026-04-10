#!/bin/bash
set -euo pipefail

echo "=== 1. Installing pinned OpenTofu v1.11.6 ==="
TOFU_VERSION="1.11.6"
ARCH=$(uname -m | sed 's/x86_64/amd64/; s/aarch64/arm64/; s/armv7l/arm/')
echo "Detected architecture: $ARCH"

curl -LO "https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_linux_${ARCH}.zip"
unzip -o "tofu_${TOFU_VERSION}_linux_${ARCH}.zip"
sudo mv -f tofu /usr/local/bin/tofu
rm -f "tofu_${TOFU_VERSION}_linux_${ARCH}.zip"

tofu --version
echo "OpenTofu successfully installed (pinned version)."

echo "=== 2. Installing k3s without Traefik ==="
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik" sh -s -

echo "=== 3. Setting up kubeconfig (persistent) ==="
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown "$(whoami):$(whoami)" ~/.kube/config
chmod 600 ~/.kube/config
export KUBECONFIG=~/.kube/config

# Persist across reboots/sessions
grep -q 'export KUBECONFIG=~/.kube/config' ~/.bashrc || \
  echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc

echo "=== 4. Running OpenTofu (infra/base) ==="
if [ -d "infra/base" ]; then
  cd infra/base
  tofu init
  echo "→ Running 'tofu apply -auto-approve' (first time: review plan manually if you prefer)"
  tofu apply -auto-approve
  cd - >/dev/null
  echo "✅ tofu apply completed."
else
  echo "⚠️  infra/base directory not found. cd into it and run 'tofu init && tofu apply' manually."
fi

echo ""
echo "=== Setup finished! ==="
echo "Next steps:"
echo "  1. Wait for Argo CD pods:   watch kubectl get pods -n argocd"
echo "  2. Launch UI securely:      ./launch-argocd-ui.sh"