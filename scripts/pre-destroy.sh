#!/bin/bash

# Cleanup script to be used before terraform destroy and avoid terraform timeouts/blockers

set -e

REGION="eu-central-1"
NAMESPACES=("kafka" "logging" "default")
EKS_CLUSTER="elk-kafka-cluster"


aws eks update-kubeconfig --name "$EKS_CLUSTER" --region "$REGION"

# Skips first line (headers) and splits into 2 columns, release and namespace to read from
echo "Uninstalling Helm charts"
helm list -A | awk 'NR>1 {print $1, $2}' | while read release namespace; do
  echo "Uninstalling $release from $namespace"
  helm uninstall "$release" -n "$namespace" --no-hooks || true
done

# Delete Kubernetes resources
for ns in "${NAMESPACES[@]}"; do
  echo "Cleaning resources in namespace: $ns"
  kubectl delete all --all -n "$ns" --ignore-not-found
  kubectl delete configmap --all -n "$ns" --ignore-not-found
  kubectl delete secret --all -n "$ns" --ignore-not-found
  kubectl delete serviceaccount --all -n "$ns" --ignore-not-found
done

# Delete CRDS
echo "Deleting Strimzi/Kafka CRDs"
kubectl delete kafka --all -A --ignore-not-found || true
kubectl delete kafkatopic --all -A --ignore-not-found || true
kubectl delete kafkabridge --all -A --ignore-not-found || true

# Remove EKS load balancer leftovers
echo "Removing EKS load balancer leftover"

VPC_ID=$(aws eks describe-cluster --name "$EKS_CLUSTER" --region "$REGION" \
  --query "cluster.resourcesVpcConfig.vpcId" --output text)

if [[ "$VPC_ID" != "None" ]]; then
  LB_NAMES=$(aws elb describe-load-balancers --region "$REGION" \
    --query "LoadBalancerDescriptions[?VPCId=='$VPC_ID'].LoadBalancerName" --output text)

  for name in $LB_NAMES; do
    echo "Deleting classic ELB: $name"
    aws elb delete-load-balancer --load-balancer-name "$name" --region "$REGION" || true
  done
fi

# Delete orphaned ENIs
echo "Deleting ENIs in VPC $VPC_ID"
ENIS=$(aws ec2 describe-network-interfaces --region "$REGION" \
  --filters Name=vpc-id,Values="$VPC_ID" Name=status,Values=available \
  --query "NetworkInterfaces[].NetworkInterfaceId" --output text)

for eni in $ENIS; do
  echo "Deleting ENI: $eni"
  aws ec2 delete-network-interface --network-interface-id "$eni" --region "$REGION" || true
done

echo "Cleanup complete"
