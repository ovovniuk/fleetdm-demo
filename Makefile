
CLUSTER_NAME   ?= fleetdm-local
NAMESPACE      ?= fleetdm
RELEASE        ?= fleetdm
CHART_PATH     ?= charts/fleetdm

.PHONY: cluster destroy install uninstall

cluster:
	minikube start -p $(CLUSTER_NAME) --cpus=4 --memory=6g

destroy:
	minikube delete -p $(CLUSTER_NAME)

install:
	rm -f $(CHART_PATH)/Chart.lock
	rm -f $(CHART_PATH)/charts/*.tgz
	helm dependency update $(CHART_PATH)
	kubectl create namespace $(NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	helm upgrade --install $(RELEASE) $(CHART_PATH) \
		--namespace $(NAMESPACE) \
		--timeout 5m

uninstall:
	-helm uninstall $(RELEASE) --namespace $(NAMESPACE)
	-kubectl delete namespace $(NAMESPACE) --ignore-not-found
