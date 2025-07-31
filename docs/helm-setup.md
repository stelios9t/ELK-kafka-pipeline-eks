# Helm Setup

## Helm repos

- helm repo add strimzi https://strimzi.io/charts/
- helm repo add elastic https://helm.elastic.co
- helm repo update

## namespaces

```bash
kubectl create ns kafka
kubectl create ns logging
```

## Install Kafka Strimzi

```bash
helm install kafka-operator strimzi/strimzi-kafka-operator -n kafka
```

## Install Elasticsearch and Kibana

```bash
helm install elasticsearch elastic/elasticsearch -n logging \
 --set replicas=1 \
 --set persistence.enabled=false

helm install kibana elastic/kibana -n logging \
 --set service.type=LoadBalancer \
 --set persistence.enabled=false
```

## Apply logstash pipeline

```bash
kubectl apply -n logging -f [logstash-configmap.yaml](../kubernetes/logstash-configmap.yaml)
```

## Install Logstash

```bash
helm upgrade --install logstash elastic/logstash -n logging \
 --set persistence.enabled=false \
 --set service.type=ClusterIP \
 --set logstashPipelineConfigMap=logstash-pipeline \
 --set service.ports[0].name=beats \
 --set service.ports[0].port=5044
```

## Deploy K8S Resources

```bash
kubectl apply -n kafka [kafka-cluster-ephemeral.yaml](../kubernetes/kafka-cluster-ephemeral.yaml)
kubectl apply -n kafka [kafka-topic.yaml](../kubernetes/kafka-topic.yaml)
kubectl apply -n kafka -f [log-generator](../kubernetes/log-generator.yaml)
```
