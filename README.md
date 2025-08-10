# RKE2-Deployment

## I. Installation
1. Single Node
    ```shell
    curl -sfL https://get.rke2.io | sudo sh -
    sudo systemctl enable rke2-server.service
    sudo systemctl start rke2-server.service
    ```
   
2. Install kubectl
    ```shell
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    ```

3. Add ```dev``` context
    ```shell
    kubectl config set-context dev \
      --cluster=default \
      --user=default \
      --namespace=dev
    ```

4. Change ```data-dir``` location
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
       ```
   - Sync files:
       ```shell
       sudo rsync -a /var/lib/rancher/rke2/ /home/tripg/Workspace/rancher/rke2/
       ```
   - Restart the RKE2 server
       ```shell
       sudo systemctl start rke2-server
       ```
  
5. Change Docker location
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