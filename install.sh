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
        UNSUPPORTED="docker-machine-driver-kvm2|minikube|docker-machine|"
        START="false"
    ;;
    armhf)
        HELM_ARCH='arm'
        KUBECTL_ARCH='arm'
        UNSUPPORTED="docker-machine-driver-kvm2|minikube|"
        START="false"
    ;;
    aarch64|arm64)
        HELM_ARCH='arm64'
        KUBECTL_ARCH='arm64'
        UNSUPPORTED="docker-machine-driver-kvm2|minikube|"
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
    curl --silent "https://github.com/${1}/releases/latest" | sed 's!.*/releases/tag/\(v\?[0-9].*\)">.*!\1!'
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
        if [ ${__type} == "binary_noarch"  ]; then
            local __sha256sum="${__cur_dir}/known_sha256sums/noarch_${__name}_${__version}"
        else
            local __sha256sum="${__cur_dir}/known_sha256sums/${ARCH}_${__name}_${__version}"
        fi
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
                binary|binary_noarch)
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
    kvm2_driver_version="${minikube_version}"
    k8s_version="$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
    helm_version="$(_latest_github_release helm/helm)"
    kubetail_version="$(_latest_github_release johanhaleby/kubetail)"
else
    echo 'Getting predefined versions.'
    source predefined_versions
fi

echo "# known versions, that work for me
minikube_version=\"${minikube_version}\"
dockermachine_version=\"${dockermachine_version}\"
kvm2_driver_version=\"${kvm2_driver_version}\"
k8s_version=\"${k8s_version}\"
helm_version=\"${helm_version}\"
kubetail_version=\"${kubetail_version}\"
" > used_versions

_minikube_url="https://storage.googleapis.com/minikube/releases/${minikube_version}/minikube-linux-${KUBECTL_ARCH}"
_kubectl_url="https://storage.googleapis.com/kubernetes-release/release/${k8s_version}/bin/linux/${KUBECTL_ARCH}/kubectl"
_dockermachine_url="https://github.com/docker/machine/releases/download/${dockermachine_version}/docker-machine-Linux-${DM_ARCH}"
_kvm2_driver_url="https://storage.googleapis.com/minikube/releases/${kvm2_driver_version}/docker-machine-driver-kvm2"
_helm_url="https://storage.googleapis.com/kubernetes-helm/helm-${helm_version}-linux-${HELM_ARCH}.tar.gz"
_kubetail_url="https://raw.githubusercontent.com/johanhaleby/kubetail/${kubetail_version}/kubetail"

export INSTALL_PATH="${HOME}/.minikube/bin/"
mkdir -p ${INSTALL_PATH}
PATH="${INSTALL_PATH}:${PATH}"

cat <<- EOF > minienv
if [[ "\${_MINIKUBE_ENV}" != "" ]]; then
    echo "MiniKube Environment already set"
else
    export PATH="${INSTALL_PATH}:\${PATH}"
    __shell=\$(basename \$(realpath /proc/\$\$/exe))

    case \${__shell} in
        bash|zsh)
            echo "## detected \${__shell}"
            echo "+ loading shell completion for kubectl"
            source <(kubectl completion \${__shell})
            echo "+ loading shell completion for minikube"
            source <(minikube completion \${__shell})
            echo "+ loading shell completion for helm"
            source <(helm completion \${__shell})
            echo "+ loading minikube docker-environment"
            eval \$(minikube docker-env)
            if [[ \${__shell} == "bash" ]]; then
                export PS1="[+] \${PS1}"
            fi
        ;;
        *)
            echo "Unknown shell"
        ;;
    esac
    export _MINIKUBE_ENV="\$(pwd)"
fi
# vim:ft=sh
EOF

_download kubectl ${k8s_version} ${_kubectl_url}
_download helm ${helm_version} ${_helm_url} tar.gz linux-${HELM_ARCH}/helm
_download kubetail ${kubetail_version} ${_kubetail_url} binary_noarch

if [[ ${TOOLS_ONLY} -eq 0 ]]; then
    _download minikube ${minikube_version} ${_minikube_url}
    _download docker-machine ${dockermachine_version} ${_dockermachine_url}
    _download docker-machine-driver-kvm2 ${kvm2_driver_version} ${_kvm2_driver_url}

    if grep -q "minikube|" <( echo "${UNSUPPORTED}" ) ; then
        echo "INFO: minikube is unsupported for ${ARCH}, can't config/start!"
    else
        echo "> minikube profile MyMinikube"
        minikube profile MyMinikube
        echo "> minikube config set kubernetes-version ${k8s_version}"
        minikube config set kubernetes-version ${k8s_version}
        echo "> minikube config set vm-driver kvm2"
        minikube config set vm-driver kvm2
        echo "> minikube config set memory ${MEMORY}"
        minikube config set memory ${MEMORY}
        echo "> minikube config set cpus ${CPUS}"
        minikube config set cpus ${CPUS}
        echo "> minikube config set disk-size ${DISK}"
        minikube config set disk-size ${DISK}

        __minkube_starter="minikube start"

        echo -ne "\n\n"
        if [[ ${START} == 'true' ]]; then
            echo "Starting Kubernetes ${k8s_version} on minikube ${minikube_version} with ${MEMORY} MiB RAM, ${CPUS} CPUs and ${DISK} disk size:"
            ${__minkube_starter}
        else
            echo "start your minikube with:"
            echo "$ ${__minkube_starter}"
        fi

        echo ""
        echo "run '. minienv' to enable your minikube-environment in your shell"
        echo ""
    fi
fi
