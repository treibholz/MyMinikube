# MyMinikube

This installs a complete minikube on a Debian-Environment with KVM.

* checks all downloaded binaries against local sha256sums
* everything ends up in ~/.minikube
* the downloaded binaries are put in ~/.minikube/bin
* unfortunatelly ~/.minikube seems to be hardcoded in minikube, so if you want to put your stuff somewhere else, you have to^W^Wcan use symlinks (e.g. ln -s /data/storage/minikube ~/.minikube), before running this installer.
* just add ~/.minikube/bin to your $PATH afterwards

## Usage:

```
$ ./install.sh -h
usage: ./install.sh [-hlIcdm]

 -h    this help
 -l    use latest versions
 -I    Only install, don' start/initialize your minikube afterwards
 -c N  number of CPUs (default=2)
 -m N  amount of memory (in MiB) to use (default=2048)
 -d N  amount of diskspace to use (default=20g)

```

## Example:
```
klaus@cyberdeck:~/MyMinikube$ ./install.sh
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

run '. minienv' to enable your minikube-environment

klaus@cyberdeck:~/MyMinikube$
```

```
klaus@cyberdeck:~/MyMinikube$ cat minienv
export PATH="/home/klaus/.minikube/bin/:${PATH}"
klaus@cyberdeck:~/MyMinikube$ source minienv
klaus@cyberdeck:~/MyMinikube$ minikube status
minikube: Running
localkube: Running
kubectl: Correctly Configured: pointing to minikube-vm at 192.168.42.182
klaus@cyberdeck:~/MyMinikube$
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

