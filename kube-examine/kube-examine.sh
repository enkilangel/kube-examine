#!/bin/bash
CLNAME=`kubectl config view -o jsonpath='{range .clusters[*]}{.name}'`

if [[ -e ./$CLNAME ]]; then
    echo "Directory with name $CLNAME on path "./$CLNAME" exits. Remove directory.."
    rm -rf ./$CLNAME
    mkdir ./$CLNAME
    mkdir ./$CLNAME/json
    mkdir ./$CLNAME/txt
else
    mkdir ./$CLNAME
    mkdir ./$CLNAME/json
    mkdir ./$CLNAME/txt
fi

## get info about nodes
echo "Export configuration about k8s nodes..."
kubectl get nodes > ./$CLNAME/txt/getNodes.txt
kubectl get nodes -o json > ./$CLNAME/json/getNodes.json

## get info about namespaces
echo "Export configuration about k8s namespaces..."
kubectl get namespaces -o json > ./$CLNAME/json/getNameSpaces.json 
kubectl get namespaces > ./$CLNAME/txt/getNameSpaces.txt

## get info about pods
echo "Export configuration about k8s pods..."
kubectl get pod --all-namespaces > ./$CLNAME/txt/getPodAllNameSpaces.txt
kubectl get pod --all-namespaces -o json > ./$CLNAME/json/getPodAllNameSpaces.json

## get info about services
echo "Export configuration about k8s services..."
kubectl get services --all-namespaces -o json > ./$CLNAME/json/getServices.json
kubectl get services --all-namespaces > ./$CLNAME/txt/getServices.txt

## get info about volumes
echo "Export configuration about k8s volumes..."
kubectl get storageclass > ./$CLNAME/txt/getStorageclass.txt
kubectl get persistentvolumeclaim --all-namespaces > ./$CLNAME/txt/getPersistentVolumeClaim.txt
kubectl get persistentvolume --all-namespaces > ./$CLNAME/txt/getPersistentVolume.txt
kubectl get storageclass -o json > ./$CLNAME/json/getStorageclass.json
kubectl get persistentvolumeclaim --all-namespaces -o json > ./$CLNAME/json/getPersistentVolumeClaim.json
kubectl get persistentvolume --all-namespaces -o json > ./$CLNAME/json/getPersistentVolume.json

## get info about jobs
echo "Export configuration about k8s jobs..."
kubectl get jobs --all-namespaces > ./$CLNAME/txt/getjobs.txt
kubectl get jobs --all-namespaces -o json > ./$CLNAME/json/getjobs.json

## get info about daemonsets
echo "Export configuration about k8s daemonset..."
kubectl get daemonset --all-namespaces > ./$CLNAME/txt/getDaemonSet.txt
kubectl get daemonset --all-namespaces -o json > ./$CLNAME/json/getDaemonSet.json

## get info about statefulsets
echo "Export configuration about k8s statefulsets..."
kubectl get statefulset --all-namespaces > ./$CLNAME/txt/getStatefulSet.txt
kubectl get statefulset --all-namespaces -o json  > ./$CLNAME/json/getStatefulSet.json

## get info about deployments
echo "Export configuration about k8s deployments..."
kubectl get deployment --all-namespaces  > ./$CLNAME/txt/getDeployment.txt
kubectl get deployment --all-namespaces -o json > ./$CLNAME/json/getDeployment.json

## get info about ingress
echo "Export configuration about k8s ingress..."
kubectl get ingress --all-namespaces > ./$CLNAME/txt/getIngress.txt
kubectl get ingress --all-namespaces -o json > ./$CLNAME/json/getIngress.json

## get info about CustomResourceDefinitions
echo "Export configuration about k8s CustomResourceDefinitions..."
kubectl get CustomResourceDefinition --all-namespaces  > ./$CLNAME/txt/getCustomResourceDefinition.txt
kubectl get CustomResourceDefinition --all-namespaces -o json > ./$CLNAME/json/getCustomResourceDefinition.json

## get info about ClusterRole
echo "Export configuration about k8s ClusterRole..."
kubectl get ClusterRole > ./$CLNAME/txt/getClusterRole.txt
kubectl get ClusterRole -o json > ./$CLNAME/json/getClusterRole.json
kubectl get ClusterRoleBindings > ./$CLNAME/txt/getClusterRoleBindings.txt
kubectl get ClusterRoleBindings -o json > ./$CLNAME/json/getClusterRoleBindings.json

## get info about role
echo "Export configuration about k8s role..."
kubectl get role --all-namespaces > ./$CLNAME/txt/getRole.txt
kubectl get role --all-namespaces -o json  > ./$CLNAME/json/getRole.json
kubectl get RoleBindings --all-namespaces > ./$CLNAME/txt/getRoleBindings.txt
kubectl get RoleBindings --all-namespaces  -o json  > ./$CLNAME/json/getRoleBindings.json

## get info about serviceaccounts
echo "Export configuration about k8s serviceaccounts..."
kubectl get serviceaccounts --all-namespaces > ./$CLNAME/txt/getServiceAccounts.txt
kubectl get serviceaccounts --all-namespaces -o json > ./$CLNAME/json/getServiceAccounts.json

## get info about PodSecurityPolicy
echo "Export configuration about k8s PodSecurityPolicy..."
kubectl get PodSecurityPolicy --all-namespaces > ./$CLNAME/txt/getPodSecurityPolicy.txt
kubectl get PodSecurityPolicy --all-namespaces -o json > ./$CLNAME/json/getPodSecurityPolicy.json

## get info about networkpolicy
echo "Export configuration about k8s networkpolicy..."
kubectl get networkpolicy --all-namespaces > ./$CLNAME/txt/getNetworkPolicy.txt
kubectl get networkpolicy --all-namespaces -o json  > ./$CLNAME/json/getNetworkPolicy.json

## get info about kube-system configMaps
echo "Export configuration about k8s kube-systm configMaps..."
kubectl get configmap -n kube-system kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' > ./$CLNAME/txt/getKubeadmConfigMap.txt
kubectl get configmap -n kube-system kubelet-config -o jsonpath='{.data.kubelet}' > ./$CLNAME/txt/getKubeletConfigMap.txt

## Run kube-bench tests
echo "Run kube-bench tests..."
kubectl apply -f kube-bench-master.yaml
kubectl apply -f kube-bench-node.yaml
KUBE_BENCH_MASTER=`kubectl get pods --selector=job-name=kube-bench-master --no-headers | awk '{print $1}'`
KUBE_BENCH_NODE=`kubectl get pods --selector=job-name=kube-bench-node --no-headers | awk '{print $1}'`
kubectl wait job kube-bench-master --for condition=complete
kubectl logs $KUBE_BENCH_MASTER > ./$CLNAME/txt/getKubeBenchMaster.txt
kubectl wait job kube-bench-node --for condition=complete
kubectl logs $KUBE_BENCH_NODE > ./$CLNAME/txt/getKubeBenchNode.txt
kubectl delete -f kube-bench-master.yaml
kubectl delete -f kube-bench-node.yaml

## archive folder
tar -czvf $CLNAME.tar.gz ./$CLNAME
