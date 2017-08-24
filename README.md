# MyMiniKube

This installs a complete minikube on a Debian-Environment with KVM.

## Prerequisities

* libvirt and kvm already working.

for more see https://gist.github.com/kevin-smets/b91a34cea662d0c523968472a81788f7

## Why all of this?

Installing k8s and minikube is a PITA. Let me show you:

### minikube

https://kubernetes.io/docs/getting-started-guides/minikube/

### install

https://kubernetes.io/docs/getting-started-guides/minikube/#installation

### installing minikube

https://kubernetes.io/docs/tasks/tools/install-minikube/

### no, I have to go back to "install" and install a driver:

https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#kvm-driver

#### go and install it from github:

https://github.com/dhiltgen/docker-machine-kvm/releases

#### before you can install this, you have to install docker-machine

https://github.com/docker/machine/releases

### Install kubectl

https://kubernetes.io/docs/tasks/tools/install-minikube/#install-kubectl

#### yes "Install kubectl"

https://kubernetes.io/docs/tasks/tools/install-kubectl/

### Install minikube

https://kubernetes.io/docs/tasks/tools/install-minikube/#install-minikube

#### get the latest release

https://github.com/kubernetes/minikube/releases
