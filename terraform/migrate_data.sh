#!/bin/bash

while [[ ! $(kubectl get pods | grep django) ]]; do
  echo -e "\r\033[1;36mWaiting for pod initialization..."
  sleep 1
done

while [[ ! $(kubectl get pods | grep django | grep Running) ]]; do
  echo -e "\r\033[1;36mWaiting for pod initialization..."
  sleep 1
done

POD_NAME=$(kubectl get pods | grep django -m 1 | cut -d ' ' -f1)

kubectl exec $POD_NAME -- /app/manage.py migrate --noinput
kubectl exec $POD_NAME -- /app/manage.py loaddata sample_admin
kubectl exec $POD_NAME -- /app/manage.py loaddata default_oauth_apps_docker
kubectl exec $POD_NAME -- /app/manage.py loaddata initial_data