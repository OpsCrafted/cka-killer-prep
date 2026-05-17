# Lab 05: Certificate Inspection

**Domain:** Architecture (25%) | **Difficulty:** Medium | **Time target:** 5 minutes

## Scenario
You need to audit the cluster's TLS certificates. Check the apiserver certificate expiry and write the commands to renew it.

## Setup
```bash
./scripts/break.sh lab-05-certificate-expired
```

<details><summary>📖 Solution</summary>

```bash
docker exec -it cka-lab-control-plane bash

# Check with openssl
openssl x509 -noout -text -in /etc/kubernetes/pki/apiserver.crt | grep Validity -A2

# Check with kubeadm
kubeadm certs check-expiration

# Write results
kubeadm certs check-expiration | grep "apiserver " > /tmp/cert-expiry.txt
echo "kubeadm certs renew apiserver" > /tmp/renew-cert.sh
```
</details>
