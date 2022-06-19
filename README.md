# Foobar

Terraform & Kubernetes Project

## Installation

Note - This assumes you already have a k8s cluster in your context
```bash 
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade -n monitoring -i <release-name> grafana/grafana -f grafana/values.yaml
```

## Usage

```bash
terraform init
terraform apply
kubectl apply -f words_counter_batch/cron.yaml
```