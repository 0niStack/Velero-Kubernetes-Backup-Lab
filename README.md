# Velero Backup Lab Demo

Kubernetes backup/restore demo with Velero.
RustFS runs inside the cluster as the S3-compatible backup target.

```
01-kind/       Kind cluster (1 control-plane + 2 workers, host :8080 -> NodePort 30080)
02-nginx/      Namespace, ConfigMap, Deployment, Service (NodePort) for nginx
03-velero/     RustFS + Velero install + backup
04-disaster/   Accidentally delete the namespace
05-restore/    Restore from backup + test
```

## Prerequisites

`docker`, `kind`, `kubectl`, `velero` CLI, `curl`

Install the Velero CLI if it's missing:

```bash
./03-velero/install-cli.sh
```

## Run

```bash
chmod +x */*.sh

# 01 - cluster
./01-kind/setup.sh

# 02 - app
./02-nginx/deploy.sh
./02-nginx/test.sh

# 03 - velero + backup
./03-velero/install.sh
./03-velero/backup.sh nginx-backup

# 04 - disaster
./04-disaster/delete.sh

# 05 - restore + test
./05-restore/restore.sh nginx-backup
./05-restore/test.sh
```

### Not using Kind?

On kubeadm or any other cluster, `localhost:8080` won't reach nginx (that mapping only exists in the Kind config). Skip `01-kind` and point the test scripts at a node IP and the NodePort instead:

```bash
export URL=http://<node-ip>:30080
./02-nginx/test.sh
./04-disaster/delete.sh
./05-restore/test.sh
```

## Useful commands

```bash
velero backup get
velero backup describe nginx-backup --details
velero backup logs nginx-backup
velero restore get
velero restore logs <restore-name>
velero backup-location get
kubectl -n velero logs deploy/velero
kubectl -n velero get pods
```

RustFS console (optional): `kubectl -n velero port-forward svc/rustfs 9001:9001`, then open http://localhost:9001 (`veleroadmin` / `velero-secret-12345`).

## Notes

- RustFS uses `emptyDir`, so backups are lost if the RustFS pod restarts. Lab only.
- The default credentials in `03-velero/rustfs.yaml` and `03-velero/credentials-velero` are for the lab. Change them for anything else.
- This backs up Kubernetes objects only (no PVC data, `--use-volume-snapshots=false`). For PVC data use Velero file-system backup (`--use-node-agent`, `--default-volumes-to-fs-backup`).
- Override the AWS plugin version if needed: `AWS_PLUGIN=velero/velero-plugin-for-aws:v1.10.0 ./03-velero/install.sh`
- Override the Velero CLI version: `VELERO_VERSION=v1.15.2 ./03-velero/install-cli.sh`
- Cleanup (Kind): `./01-kind/teardown.sh`
- Cleanup (other clusters): `kubectl delete namespace demo velero`

## Troubleshooting

| Symptom | Check |
|---|---|
| `ImagePullBackOff` in `velero` namespace | `kubectl -n velero describe pod`: the node may not reach Docker Hub |
| `velero backup-location get` shows `Unavailable` | `kubectl -n velero logs deploy/velero`: usually the bucket, endpoint or credentials |
| Restore shows `PartiallyFailed` | `velero restore logs <restore-name>` |
| nginx test fails after restore | Wait for pods: `kubectl -n demo get pods`, and check you're using the right `URL` |
