#!/bin/bash -e

export LANG=C
export INSTALL_PATH="${HOME}/.minikube/bin/"
mkdir -p ${INSTALL_PATH}
PATH="${INSTALL_PATH}:${PATH}"
echo "export PATH=\"${INSTALL_PATH}:\${PATH}\"" > minienv

# get latest release on github
minikube_version="$(curl --silent 'https://github.com/kubernetes/minikube/releases/latest' | sed 's!.*/releases/tag/\(v[0-9].*\)">.*!\1!')"
dockermachine_version="$(curl --silent 'https://github.com/docker/machine/releases/latest' | sed 's!.*/releases/tag/\(v[0-9].*\)">.*!\1!')"
kvm_driver_version="$(curl --silent 'https://github.com/dhiltgen/docker-machine-kvm/releases/latest' | sed 's!.*/releases/tag/\(v[0-9].*\)">.*!\1!')"
# Dynamic
kubectl_version="$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"

_minikube_url="https://storage.googleapis.com/minikube/releases/${minikube_version}/minikube-linux-amd64"
_kubectl_url="https://storage.googleapis.com/kubernetes-release/release/${kubectl_version}/bin/linux/amd64/kubectl"
_dockermachine_url="https://github.com/docker/machine/releases/download/${dockermachine_version}/docker-machine-Linux-x86_64"
_kvm_driver_url="https://github.com/dhiltgen/docker-machine-kvm/releases/download/${kvm_driver_version}/docker-machine-driver-kvm-ubuntu16.04"

_download () {
    local __name=$1
    local __version=$2
    local __url=$3

    local __cur_dir="$(pwd)"
    local __sha256sum="${__cur_dir}/known_sha256sums/${__name}_${__version}"
    local __download=1

    echo "Downloading ${__name} version ${__version}"

    if [[ -f ${INSTALL_PATH}/${__name} ]]; then
        if [[ -f ${__sha256sum}  ]]; then
            cd ${INSTALL_PATH}
            echo -ne "Checking sha256sum of locally available "
            
            if sha256sum -c ${__sha256sum}; then
                echo "no need to download."
                __download=0
            else
                echo "${__name} is not the expected file, dowloading again..."
            fi
            cd ${__cur_dir}
        fi
    fi
    
    if [[ $__download -gt 0 ]]; then
        curl --progress-bar -Lo ${INSTALL_PATH}/${__name} ${__url}
 
        cd ${INSTALL_PATH}
        if [[ -f ${__sha256sum}  ]]; then
            echo -ne "Checking sha256sum of "
            sha256sum -c ${__sha256sum}
            cd ${__cur_dir}
        else
            echo "Warning: Unknown version (${__version}, can't check sha256sum of ${__name}."
            echo "         Generating new sha256sum for later"
            sha256sum ${__name} > ${__sha256sum}
            cd ${__cur_dir}
            git add ${__sha256sum}
            git commit -m "New sha256sum for ${__name} ${__version}"
        fi
    fi

    chmod +x ${INSTALL_PATH}/${__name}
    echo ""
}

_download minikube ${minikube_version} ${_minikube_url}
_download kubectl ${kubectl_version} ${_kubectl_url}
_download docker-machine ${dockermachine_version} ${_dockermachine_url}
_download docker-machine-driver-kvm ${kvm_driver_version} ${_kvm_driver_url}

minikube start --vm-driver=kvm

echo "" 
echo "run '. minienv' to enable your minikube-environment"
echo "" 
