# velero-backup-lab

Kubernetes backup/restore demo with Velero on Kind.
MinIO runs inside the cluster as the S3-compatible backup target.

```
01-kind/       Kind cluster (1 control-plane + 2 workers, host :8080 -> NodePort 30080)
02-nginx/      Namespace, ConfigMap, Deployment, Service (NodePort) for nginx
03-velero/     MinIO + Velero install + backup
04-disaster/   Accidentally delete the namespace
05-restore/    Restore from backup + test
```

## Prerequisites
`docker`, `kind`, `kubectl`, `velero` CLI, `curl`

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

## Useful commands

```bash
velero backup get
velero backup describe nginx-backup --details
velero backup logs nginx-backup
velero restore get
velero restore logs <restore-name>
kubectl -n velero logs deploy/velero
```

MinIO console (optional): `kubectl -n velero port-forward svc/minio 9001:9001`, then open http://localhost:9001 (minio / minio12345).

## Notes
- MinIO uses `emptyDir`, so backups are lost if the MinIO pod restarts. Lab only.
- This backs up Kubernetes objects only (no PVC data, `--use-volume-snapshots=false`). Kind's default storage has no snapshot support; for PVC data use Velero file-system backup (`--use-node-agent`, `--default-volumes-to-fs-backup`).
- Override the AWS plugin version if needed: `AWS_PLUGIN=velero/velero-plugin-for-aws:v1.10.0 ./03-velero/install.sh`
- Cleanup: `./01-kind/teardown.sh`
