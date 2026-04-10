
# Infrastructure: Argo CD on K3s

This repository contains the automation scripts and Infrastructure as Code (IaC) to provision a local Kubernetes cluster and deploy Argo CD using **OpenTofu**.

## 🏗️ Architecture
- **Orchestrator:** [K3s](https://k3s.io/) (Lightweight Kubernetes, Traefik disabled).
- **IaC Engine:** [OpenTofu](https://opentofu.org/) (v1.11.6 pinned).
- **GitOps:** Argo CD (Deployed via OpenTofu in `infra/base`).


## 🚀 Quick Start

### 1. Provision the Cluster
The setup script installs OpenTofu, configures K3s, and applies the base infrastructure.
```bash
chmod +x setup-cluster.sh launch-argocd-ui.sh
./setup-cluster.sh
```

### 2. Verify Readiness
Wait until all pods in the `argocd` namespace show a `Running` status:
```bash
watch kubectl get pods -n argocd
```

### 3. Launch the UI
Access the Argo CD dashboard securely. This script handles port-forwarding and retrieves your admin credentials.
```bash
./launch-argocd-ui.sh
```


## 🔐 Credentials & Security

- **Username:** `admin`
- **Initial Password:** Stored at `~/.kube/argocd-initial-admin.password` (Restricted access).
- **Note:** It is recommended to change the admin password in the UI immediately and delete the initial secret:
  ```bash
  kubectl -n argocd delete secret argocd-initial-admin-secret
  ```

## 🛠️ Troubleshooting

- **Permissions:** If you encounter `Permission denied` when running `tofu`, ensure your `KUBECONFIG` is active: `source ~/.bashrc`.
- **Port 8080:** If the UI script fails to start, check if another process is using port 8080:
  `sudo lsof -i :8080`
- **Manual Cleanup:** To stop the UI tunnel without closing the terminal:
  `pkill -f "port-forward svc/argocd-server"`
