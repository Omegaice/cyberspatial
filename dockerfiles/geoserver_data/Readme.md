# Data directory for Kubenetes Minikube

This is a data directory to be mounted at /data in minikube. From repository root:
```bash
# minikube mount ./data:/data
```

The kubernetes configs mount /data/pv0001 as postgresql and /data/pv0002 as geoserver data directories. The default geoserver data directories are not stored in github but can be generated by the geoserver_data.sh script in the data directory.
