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
usage: ./install.sh [-hlIcdmDT]

 -h    this help
 -l    use latest versions
 -I    Only install, don' start/initialize your minikube afterwards
 -c N  number of CPUs (default=2 (half of your host))
 -m N  amount of memory (in MiB) to use (default=2048)
 -d N  amount of diskspace to use (default=20g)
 -D    DEBUG Infos
 -T    Tools only, no minikube and kvm-stuff, and don't start anything

```

## Example:
```
klaus@cyberdeck:~/MyMinikube$ ./install.sh
Getting predefined versions.
Downloading kubectl version v1.13.2
######################################################################## 100.0%
Checking sha256sum of kubectl: OK

Downloading helm version v2.12.2
######################################################################## 100.0%
Checking sha256sum of helm: OK

Downloading kubetail version 1.6.5
######################################################################## 100.0%
Checking sha256sum of kubetail: OK

Downloading minikube version v0.32.0
######################################################################## 100.0%
Checking sha256sum of minikube: OK

Downloading docker-machine version v0.16.1
######################################################################## 100.0%
Checking sha256sum of docker-machine: OK

Downloading docker-machine-driver-kvm2 version v0.32.0
######################################################################## 100.0%
Checking sha256sum of docker-machine-driver-kvm2: OK

> minikube profile MyMinikube
minikube profile was successfully set to MyMinikube
> minikube config set kubernetes-version v1.13.2
> minikube config set vm-driver kvm2
These changes will take effect upon a minikube delete and then a minikube start
> minikube config set memory 2048
These changes will take effect upon a minikube delete and then a minikube start
> minikube config set cpus 2
These changes will take effect upon a minikube delete and then a minikube start
> minikube config set disk-size 20g
These changes will take effect upon a minikube delete and then a minikube start


Starting Kubernetes v1.13.2 on minikube v0.32.0 with 2048 MiB RAM, 2 CPUs and 20g disk size:
Starting local Kubernetes v1.13.2 cluster...
Starting VM...
Downloading Minikube ISO
 178.88 MB / 178.88 MB [============================================] 100.00% 0s
Getting VM IP address...
Moving files into cluster...
Downloading kubeadm v1.13.2
Downloading kubelet v1.13.2
Finished Downloading kubeadm v1.13.2
Finished Downloading kubelet v1.13.2
Setting up certs...
Connecting to cluster...
Setting up kubeconfig...
Stopping extra container runtimes...
Starting cluster components...
Verifying kubelet health ...
Verifying apiserver health ...Kubectl is now configured to use the cluster.
Loading cached images from config file.


Everything looks great. Please enjoy minikube!

run '. minienv' to enable your minikube-environment in your shell

klaus@cyberdeck:~/MyMinikube$
```

the minienv works for bash and zsh.

```
klaus@cyberdeck:~/MyMinikube$ source minienv 
## detected bash
+ loading shell completion for kubectl
+ loading shell completion for minikube
+ loading shell completion for helm
+ loading minikube docker-environment
[+] klaus@cyberdeck:~/MyMinikube$
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

