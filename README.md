# Terraform

As part of the Cloud Infrastructure course at IMT Atlantique Engineering School, this [lab](lab.md) is about deploying a distributed voting application on Docker, Kubernetes, and Proxmox using Terraform.

## Prerequisites

Make sure you have Terraform and Docker installed on your machine. You also need to have access to a Kubernetes cluster.

## Deploying the system with Terraform on your local Docker

![voting-app-docker](figures/login-nuage-voting.drawio.svg)

To deploy the system using Terraform on Docker, navigate to the `terraform/docker` directory and run:

```sh
terraform init
terraform apply
```

The application will be deployed on your local Docker environment. You should see an output similar to the following after completion:
![docker-deployment-output](figures/docker-deployment-terminal-output.png)

## Deploying the system with Terraform on Kubernetes cluster

![voting-app-k8s](figures/login-nuage-voting-k8s.drawio.svg)

To deploy the system using Terraform on Kubernetes, navigate to the `terraform/k8s` directory and run:

```sh
export KUBECONFIG=kubeconfig
terraform apply -var="kubeconfig_path=$KUBECONFIG"
terraform apply
```

Make sure to replace `kubeconfig` with the path to your actual kubeconfig file if it's located elsewhere. You should see an output similar to the following after completion:

![k8s-deployment-output](figures/k8s-deployment-terminal-output.png)
