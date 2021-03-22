helm uninstall harbor -n clt-devops

kubectl -n clt-devops delete pvc data-harbor-harbor-redis-0
kubectl -n clt-devops delete pvc data-harbor-harbor-trivy-0
kubectl -n clt-devops delete pvc database-data-harbor-harbor-database-0
kubectl -n clt-devops delete pvc harbor-harbor-chartmuseum
kubectl -n clt-devops delete pvc harbor-harbor-jobservice
kubectl -n clt-devops delete pvc harbor-harbor-registry

kubectl delete pv harbor-cm-pv
kubectl delete pv harbor-db-pv
kubectl delete pv harbor-js-pv
kubectl delete pv harbor-redis-pv
kubectl delete pv harbor-registry-pv
kubectl delete pv harbor-trivy-pv