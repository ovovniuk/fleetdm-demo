# FleetDM Helm Chart

Deploys [FleetDM](https://fleetdm.com/) with a bundled MySQL and Redis backend to any Kubernetes cluster, with a Makefile for spinning up a local minikube cluster.


## Installation

```bash
# 1. Create a local minikube cluster
make cluster

# 2. Install the chart 
make install

# 3. Verify everything is running
kubectl get all -n fleetdm
# expect: 3 pods in Running status
curl -w "HTTP %{http_code}\n" localhost:30080/healthz
# expect: HTTP 200
kubectl exec -n fleetdm -it fleetdm-mysql-0 -- \
  mysql -u fleet -p"$(kubectl get secret -n fleetdm fleetdm-mysql -o jsonpath='{.data.mysql-password}' | base64 -d)" \
  -e "SHOW TABLES;" fleet
# expect: a list of tables
kubectl exec -n fleetdm -it fleetdm-redis-master-0 -- redis-cli PING
# expect: PONG

# fleet ui is exposed by default via NodePort on localhost:30080, so to check agent connectivity, navigate to the ui and follow the host enrollment instructions
```
## Teardown

```bash
make uninstall  # removes the Helm release and the "fleetdm" namespace
make destroy    # deletes the local minikube cluster
```




