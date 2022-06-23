# Architecture Project
![example workflow](https://github.com/org-ofirdassa9/docs/actions/workflows/cd.yml/badge.svg)

Terraform & Kubernetes Project

## Installation

Note - This assumes you already have a k8s cluster in your context
```bash 
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add elastic https://helm.elastic.co
helm repo update
```

## Usage

```bash
terraform init
terraform apply
helm upgrade -n monitoring -i <release-name> grafana/grafana -f grafana/values.yaml
helm upgrade -i <release-name> elastic/elasticsearch -f elasticsearch/values.yaml 
```