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