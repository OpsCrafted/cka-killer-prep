# Lab 10: Kubelet Misconfigured

## Scenario

A worker node in the cluster has become unresponsive. New pods cannot be scheduled on it, and the node is stuck in `NotReady` state.

When you SSH to the node and check kubelet status, you find it's **not running or crashing repeatedly**. The issue is in the kubelet configuration.

## What's Broken

The kubelet process was started with a `--config` flag pointing to a **non-existent or invalid configuration file**. Kubelet crashes immediately because it can't read its config.

Possible causes:
- Config file path is wrong (typo or deleted path)
- Config file was deleted
- Config file has YAML syntax errors

## Your Task

1. **SSH to the worker node**
2. **Check kubelet status** to see the error
3. **Find the kubelet config path** referenced in systemd or the running process
4. **Verify the config file exists** and has valid YAML
5. **Fix the path or config file**
6. **Restart kubelet**
7. **Verify the node returns to Ready state**

## Commands to Get Started

```bash
ssh <worker-ip>
sudo systemctl status kubelet
sudo journalctl -u kubelet -n 50
ps aux | grep kubelet
sudo cat /etc/kubernetes/kubelet.conf
sudo find /etc/kubernetes -name "*kubelet*"
```

## What You Should See

Before fix: kubelet status shows failed or error messages
After fix: `kubectl get nodes` shows the worker as Ready

## Solution Outline

1. Check systemd service file to see what `--config` path is set
2. Verify the config file exists at that path
3. If the path is wrong, edit the service file and correct it
4. Reload systemd and restart kubelet
5. Verify with `kubectl get nodes`
