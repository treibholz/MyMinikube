#!/bin/bash -e

export LANG=C
LATEST="false"
START="true"
MEMORY=2048
CPUS="$(($(nproc)/2))"
DISK='20g'
ARCH="$(dpkg --print-architecture)"
DEBUG=0

DM_ARCH=${ARCH}
HELM_ARCH=${ARCH}
KUBECTL_ARCH=${ARCH}
UNSUPPORTED=""
TOOLS_ONLY=0

case ${ARCH} in
    arm)
        UNSUPPORTED="docker-machine-driver-kvm|minikube|docker-machine|"
        START="false"
    ;;
    armhf)
        HELM_ARCH='arm'
        KUBECTL_ARCH='arm'
        UNSUPPORTED="docker-machine-driver-kvm|minikube|"
        START="false"
    ;;
    aarch64|arm64)
        HELM_ARCH='arm64'
        KUBECTL_ARCH='arm64'
        UNSUPPORTED="docker-machine-driver-kvm|minikube|"
        START="false"
    ;;
    amd64)
        DM_ARCH='x86_64'
    ;;
esac

usage () { # {{{
    echo "usage: ${0} [-hlIcdmDT]"
    echo ""
    echo " -h    this help"
    echo " -l    use latest versions"
    echo " -I    Only install, don' start/initialize your minikube afterwards"
    echo " -c N  number of CPUs (default=${CPUS} (half of your host))"
    echo " -m N  amount of memory (in MiB) to use (default=${MEMORY})"
    echo " -d N  amount of diskspace to use (default=${DISK})"
    echo " -D    DEBUG Infos"
    echo " -T    Tools only, no minikube and kvm-stuff, and don't start anything"
    echo ""
} # }}}

while getopts "hlIm:c:d:DT" OPTION; do # {{{
    case ${OPTION} in
        h)
            usage
            exit 255
        ;;
        l)
            LATEST="true"
        ;;
        I)
            START="false"
        ;;
        m)
            MEMORY=${OPTARG}
        ;;
        c)
            CPUS=${OPTARG}
        ;;
        d)
            DISK=${OPTARG}
        ;;
        D)
            DEBUG=1
        ;;
        T)
            TOOLS_ONLY=1
            START="false"
        ;;
    esac
done # }}}

_latest_github_release () { # {{{
    curl --silent "https://github.com/${1}/releases/latest" | sed 's!.*/releases/tag/\(v[0-9].*\)">.*!\1!'
} # }}}

__debug () { # {{{
    if [[ ${DEBUG} -gt 0 ]]; then
        echo -ne '*** DEBUG: '
        return 0
    else
        return 1
    fi
} # }}}

_download () { # {{{
    local __name=$1
    local __version=$2
    local __url=$3
    local __type=${4:-binary}
    local __tar_path=${5}

    if grep -q "${__name}|" <( echo "${UNSUPPORTED}" ) ; then
        echo "INFO: ${__name} is unsupported for ${ARCH}, can't download!"
    else

        local __cur_dir="$(pwd)"
        local __sha256sum="${__cur_dir}/known_sha256sums/${ARCH}_${__name}_${__version}"
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
                    echo "${__name} is not the expected file, downloading again..."
                fi
                cd ${__cur_dir}
            fi
        fi
        
        if [[ $__download -gt 0 ]]; then
            __debug && echo ${__url} 
            case ${__type} in
                binary)
                    curl --progress-bar -Lo ${INSTALL_PATH}/${__name} ${__url}
                ;;
                tar.gz)
                    __components="$(echo ${__tar_path} |  grep -Eo '/' | wc -l)"
                    curl --progress-bar ${__url} \
                        | tar -zx -C ${INSTALL_PATH} --strip-components ${__components} ${__tar_path}
            esac

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
    fi
    echo ""
} # }}}

if [[ ${LATEST} == 'true' ]]; then
    echo 'Getting latest versions! \o/'
    minikube_version="$(_latest_github_release kubernetes/minikube)"
    dockermachine_version="$(_latest_github_release docker/machine)"
    kvm_driver_version="$(_latest_github_release dhiltgen/docker-machine-kvm)"
    kubectl_version="$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
    helm_version="$(_latest_github_release helm/helm)"
else
    echo 'Getting predefined versions.'
    minikube_version="v0.28.0"
    dockermachine_version="v0.15.0"
    kvm_driver_version="v0.10.0"
    kubectl_version="v1.11.0"
    helm_version="v2.9.1"
fi

_minikube_url="https://storage.googleapis.com/minikube/releases/${minikube_version}/minikube-linux-${KUBECTL_ARCH}"
_kubectl_url="https://storage.googleapis.com/kubernetes-release/release/${kubectl_version}/bin/linux/${KUBECTL_ARCH}/kubectl"
_dockermachine_url="https://github.com/docker/machine/releases/download/${dockermachine_version}/docker-machine-Linux-${DM_ARCH}"
_kvm_driver_url="https://github.com/dhiltgen/docker-machine-kvm/releases/download/${kvm_driver_version}/docker-machine-driver-kvm-ubuntu16.04"
_helm_url="https://storage.googleapis.com/kubernetes-helm/helm-${helm_version}-linux-${HELM_ARCH}.tar.gz"

export INSTALL_PATH="${HOME}/.minikube/bin/"
mkdir -p ${INSTALL_PATH}
PATH="${INSTALL_PATH}:${PATH}"

cat <<- EOF > minienv
export PATH="${INSTALL_PATH}:\${PATH}"
__shell=\$(basename \$(realpath /proc/\$\$/exe))

case \${__shell} in
    bash)
        echo "detected bash"
        source <(kubectl completion bash)
        source <(minikube completion bash)
        source <(helm completion bash)
        eval \$(minikube docker-env)
        PS1="[+] \${PS1}"
    ;;
    zsh)
        echo "detected zsh"
        source <(kubectl completion zsh)
        source <(minikube completion zsh)
        source <(helm completion zsh)
        eval \$(minikube docker-env)
    ;;
    *)
        echo "Unknown shell"
    ;;
esac
# vim:ft=sh
EOF


_download kubectl ${kubectl_version} ${_kubectl_url}
_download helm ${helm_version} ${_helm_url} tar.gz linux-${HELM_ARCH}/helm

if [[ ${TOOLS_ONLY} -eq 0 ]]; then
    _download minikube ${minikube_version} ${_minikube_url}
    _download docker-machine ${dockermachine_version} ${_dockermachine_url}
    _download docker-machine-driver-kvm ${kvm_driver_version} ${_kvm_driver_url}
fi

if [[ ${START} == 'true' ]]; then
    echo "Starting minikube with ${MEMORY} MiB RAM, ${CPUS} CPUs and ${DISK} disk size:" 
    minikube start --vm-driver=kvm --memory=${MEMORY} --cpus=${CPUS} --disk-size=${DISK}
else
    echo "create your minikube with:"
    echo "$ minikube start --vm-driver=kvm --memory=${MEMORY} --cpus=${CPUS} --disk-size=${DISK}"
fi

echo "" 
echo "run '. minienv' to enable your minikube-environment in your shell"
echo "" 
