# Helm Setup

## Helm repos

helm repo add strimzi https://strimzi.io/charts/
helm repo add elastic https://helm.elastic.co
helm repo update

## namespaces

kubectl create ns kafka
kubectl create ns logging

## Install Kafka Strimzi

helm install kafka-operator strimzi/strimzi-kafka-operator -n kafka

## Install Elasticsearch and Kibana

helm install elasticsearch elastic/elasticsearch -n logging \
 --set replicas=1 \
 --set persistence.enabled=false

helm install kibana elastic/kibana -n logging \
 --set service.type=LoadBalancer \
 --set persistence.enabled=false

## Apply logstash pipeline

kubectl apply -n logging -f [logstash-configmap.yaml](../kubernetes/logstash-configmap.yaml)

## Install Logstash

helm upgrade --install logstash elastic/logstash -n logging \
 --set persistence.enabled=false \
 --set service.type=ClusterIP \
 --set-file logstashPipeline=/dev/null \
 --set logstashPipelineConfigMap=logstash-pipeline
