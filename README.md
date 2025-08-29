# RKE2-Deployment
This is my personal ***homelab*** helm deployment with RKE2 which does not use any of the Bitnami helm charts

## Progress
  - [x] Local Path Provisioner
  - [x] GPU-Operator (with DCGM Exporter)
  - [x] Cert Manager
  - [x] PostgreSQL
  - [x] MariaDB
  - [x] MySQL
  - [x] Cassandra
  - [ ] Elasticsearch
  - [x] Redis
  - [x] Keycloak
  - [x] EMQX
  - [x] Centrifugo
  - [ ] Harbor Registry
  - [x] Ingress
  - [ ] MLFlow (Artifacts to MinIO, DB to Postgres)
  - [ ] Kubeflow
  - [ ] KServe/Seldon
  - [ ] Airflow
  - [ ] Superset
  - [ ] Prometheus/Grafana
  - [ ] Openmetadata
  - [ ] DataHub
  - [ ] Oauth2-Proxy

## Planned
  - [ ] CDC: Debezium + Kafka/Redpanda or NATS JetStream.
  - [ ] Apache Flink: Streaming
  - [ ] ReductStore: Hot telemetry + ROS2 storage-
  - [ ] OIDC Integration
  - [ ] Velero: Cluster Backup

## I. Installation
### 1. Single Node
    ```shell
    curl -sfL https://get.rke2.io | sudo sh -
    sudo systemctl enable rke2-server.service
    sudo systemctl start rke2-server.service
    ```

### 2. Install kubectl
    ```shell
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    ```

### 3. Add ```dev``` context
    ```shell
    kubectl config set-context dev \
      --cluster=default \
      --user=default \
      --namespace=dev
    ```

### 4. Change ```data-dir``` location
   - Stop rke2 
       ```shell
       sudo systemctl stop rke2-server
       sudo systemctl stop rke2-agent
       ```
   - Create ```config.yaml```
       ```shell
       touch /etc/rancher/rke2/config.yaml
       ```
   - Add the ```data-dir``` to the config file:
       ```text
       data-dir: "/home/tripg/Workspace/rancher/rke2"
       disable: rke2-ingress-nginx
       enable-servicelb: true
       ```
   - Sync files:
       ```shell
       sudo rsync -a /var/lib/rancher/rke2/ /home/tripg/Workspace/rancher/rke2/
       ```
   - Restart the RKE2 server
       ```shell
       sudo systemctl start rke2-server
       ```

### 5. Change Docker location
   - Create ```daemon.json``` file:
       ```shell
       touch /etc/docker/daemon.json
       ```
   - Modify the ```/etc/docker/daemon.json``` config:
       ```shell
       {
           "data-root": "/home/tripg/Workspace/docker"
       }
       ```
     
## II. Deployment
### 1. Common Arguments
    - Command:
      - `helmfile init`: Initialize the helmfile, includes version checking and installation of helm and plug-ins
      - `helmfile list`: list all the releases
      - `helmfile template`: run helm templateon all releases, useful for debugging
      - `helmfile sync`: run helm upgrade --install on all releases
      - `helmfile apply`: look at what is already present in the cluster, and run helm upgrade --install only on releases that changed
      - `helmfile diff`: only run the diff
      - `helmfile destroy`: uninstall all releases
    - Args:
      - `-f, --file helmfile.yaml`: load config from file or directory
      - `-e, --environment`: specify the environment name
      - `--selector name=ingress`: Only run using the releases that match labels
      - `--skip-deps`: skip running `helm repo update` and `helm dependency build`
      - `--disable-force-update`: do not force helm repos to update when executing `helm repo add`

### 2. Init ```helmfile```:
    ```shell
    helmfile init -i
    ```

### 3. Install all components:
    ```shell
    helmfile apply -i -e dev --disable-force-update --skip-deps --include-needs --selector group=infra
    helmfile apply -i -e dev --disable-force-update --skip-deps --include-needs --selector group=init
    ```

### 4. Install individual components:
    ```shell
    helmfile apply -i -e dev --disable-force-update --skip-deps --selector name=keycloak
    ```

### 5. Uninstall everything:
    ```shell
    helmfile destroy -i -e dev --disable-force-update
    ```
   
## III. GPU Operator
### 1. Install ```NVIDIA``` container runtime:
Follow instructions on [container runtime](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

### 2. Install ```gpu-operator```:
Follow instructions on [gpu operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html)

### 3. Troubleshooting:
[Troubleshoot](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/24.9.1/troubleshooting.html)


## IV. Troubleshooting
### 1. Too many open files
caused by running out of inotify resources. Resource limits are defined by fs.inotify.max_user_watches and 
fs.inotify.max_user_instances system variables. For example, in Ubuntu these default to 8192 and 128 respectively, 
which is not enough to create a cluster with many nodes. 

Mofidy the ```/etc/sysctl.conf```
```shell
fs.inotify.max_user_watches = 2099999999
fs.inotify.max_user_instances = 2099999999
fs.inotify.max_queued_events = 2099999999
vm.max_map_count=262144
```
Then run:
```shell
sudo sysctl --system
```