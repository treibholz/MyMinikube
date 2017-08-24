# MyMiniKube

This installs a complete minikube on a Debian-Environment with KVM.

* checks all downloaded binaries against local sha256sums
* everything ends up in ~/.minicube
* the downloaded binaries are in ~/.minicube/bin
* just add ~/.minicube/bin to your $PATH afterwards

## Usage:

```
klaus@cyberdeck:~/minikube$ ./install.sh
Downloading minikube version v0.21.0
######################################################################## 100.0%
Checking sha256sum of minikube: OK

Downloading kubectl version v1.7.4
######################################################################## 100.0%
Checking sha256sum of kubectl: OK

Downloading docker-machine version v0.12.2
######################################################################## 100.0%
Checking sha256sum of docker-machine: OK

Downloading docker-machine-driver-kvm version v0.10.0
######################################################################## 100.0%
Checking sha256sum of docker-machine-driver-kvm: OK

Starting local Kubernetes v1.7.0 cluster...
Starting VM...
Downloading Minikube ISO
 97.80 MB / 97.80 MB [==============================================] 100.00% 0s
Getting VM IP address...
Moving files into cluster...
Setting up certs...
Starting cluster components...
Connecting to cluster...
Setting up kubeconfig...
Kubectl is now configured to use the cluster.

run '. minienv' to enable your minicube-environment

klaus@cyberdeck:~/minikube$
```

```
klaus@cyberdeck:~/minikube$ cat minienv
export PATH="/home/klaus/.minikube/bin/:${PATH}"
klaus@cyberdeck:~/minikube$ source minienv
klaus@cyberdeck:~/minikube$ minikube status
minikube: Running
localkube: Running
kubectl: Correctly Configured: pointing to minikube-vm at 192.168.42.182
klaus@cyberdeck:~/minikube$
```


## Prerequisities

* libvirt and kvm already working.

for more see https://gist.github.com/kevin-smets/b91a34cea662d0c523968472a81788f7

## Why all of this?

Installing k8s and minikube is a PITA. Let me show you:

#### minikube

https://kubernetes.io/docs/getting-started-guides/minikube/

#### install

https://kubernetes.io/docs/getting-started-guides/minikube/#installation

#### installing minikube

https://kubernetes.io/docs/tasks/tools/install-minikube/

#### no, I have to go back to "install" and install a driver:

https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#kvm-driver

##### go and install it from github:

https://github.com/dhiltgen/docker-machine-kvm/releases

##### before you can install this, you have to install docker-machine

https://github.com/docker/machine/releases

#### Install kubectl

https://kubernetes.io/docs/tasks/tools/install-minikube/#install-kubectl

##### yes "Install kubectl"

https://kubernetes.io/docs/tasks/tools/install-kubectl/

#### Install minikube

https://kubernetes.io/docs/tasks/tools/install-minikube/#install-minikube

##### get the latest release

https://github.com/kubernetes/minikube/releases

