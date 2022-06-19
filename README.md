# Foobar

Terraform & Kubernetes Project

## Installation

Note - This assumes you already have a k8s cluster in your context
```bash 
helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade -i grafana bitnami/grafana
```

## Usage

```bash
terraform init
terraform apply
kubectl apply -f words_counter_batch/cron.yaml
```