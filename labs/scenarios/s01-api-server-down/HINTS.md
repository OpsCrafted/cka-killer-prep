# Hints for s01: API Server Down

## Hint 1 — Where to start

The API server is a static pod managed by kubelet. It lives in:
```
/etc/kubernetes/manifests/kube-apiserver.yaml
```
Access the control plane node: `docker exec -it <cluster>-control-plane bash`

## Hint 2 — Check why it's crashlooping

Inside the control plane node:
```bash
crictl ps -a | grep apiserver        # see restart count
crictl logs <container-id>           # read the error
```
Or via kubelet: `journalctl -u kubelet -n 50`

## Hint 3 — What to look for in the logs

Look for connection errors to a specific address and port.
The API server depends on etcd — what port does etcd listen on?

## Hint 4 — Fix it

Edit the static pod manifest. Kubelet watches that directory and restarts the pod automatically within ~10s.
```bash
vi /etc/kubernetes/manifests/kube-apiserver.yaml
```
After saving, watch: `crictl ps | grep apiserver` until STATUS = Running
