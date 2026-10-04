#!/usr/bin/env bash

set -Eeuo pipefail

# Idempotent Minikube workstation setup for supported 64-bit Ubuntu releases.
# Existing Docker, kubectl, and Minikube installations are left unchanged.

readonly INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

log() {
    printf '\n==> %s\n' "$*"
}

die() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

as_root() {
    if (( EUID == 0 )); then
        "$@"
    else
        sudo "$@"
    fi
}

command -v apt-get >/dev/null 2>&1 || die "This script supports Ubuntu systems that use apt."
[[ -r /etc/os-release ]] || die "Cannot determine the operating system."

# shellcheck source=/dev/null
. /etc/os-release
[[ "${ID:-}" == "ubuntu" ]] || die "Unsupported distribution '${ID:-unknown}'; Ubuntu is required."

case "$(dpkg --print-architecture)" in
    amd64) readonly BINARY_ARCH="amd64" ;;
    arm64) readonly BINARY_ARCH="arm64" ;;
    *) die "Only amd64 and arm64 architectures are supported." ;;
esac

if (( EUID != 0 )); then
    command -v sudo >/dev/null 2>&1 || die "sudo is required when not running as root."
fi

if ! command -v curl >/dev/null 2>&1; then
    log "Installing download prerequisites"
    as_root apt-get update
    as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl
fi

if ! command -v docker >/dev/null 2>&1; then
    log "Installing Docker Engine from Docker's official apt repository"
    as_root apt-get update
    as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl
    as_root install -m 0755 -d /etc/apt/keyrings
    as_root curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        -o /etc/apt/keyrings/docker.asc
    as_root chmod a+r /etc/apt/keyrings/docker.asc

    docker_source="$(mktemp)"
    trap 'rm -f "${docker_source:-}"; rm -rf "${download_dir:-}"' EXIT
    cat >"$docker_source" <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME:-$VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
    as_root install -m 0644 "$docker_source" /etc/apt/sources.list.d/docker.sources
    as_root apt-get update
    as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    log "Docker is already installed; leaving it unchanged"
fi

download_dir="$(mktemp -d)"
trap 'rm -f "${docker_source:-}"; rm -rf "${download_dir:-}"' EXIT

if ! command -v kubectl >/dev/null 2>&1; then
    log "Installing the latest stable kubectl"
    kubectl_version="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
    kubectl_url="https://dl.k8s.io/release/${kubectl_version}/bin/linux/${BINARY_ARCH}/kubectl"
    curl -fsSL "$kubectl_url" -o "$download_dir/kubectl"
    curl -fsSL "${kubectl_url}.sha256" -o "$download_dir/kubectl.sha256"
    (
        cd "$download_dir"
        printf '%s  kubectl\n' "$(cat kubectl.sha256)" | sha256sum --check --status
    ) || die "kubectl checksum verification failed."
    as_root install -m 0755 "$download_dir/kubectl" "$INSTALL_DIR/kubectl"
else
    log "kubectl is already installed; leaving it unchanged"
fi

if ! command -v minikube >/dev/null 2>&1; then
    log "Installing the latest stable Minikube"
    minikube_url="https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-${BINARY_ARCH}"
    curl -fsSL "$minikube_url" -o "$download_dir/minikube"
    curl -fsSL "${minikube_url}.sha256" -o "$download_dir/minikube.sha256"
    (
        cd "$download_dir"
        printf '%s  minikube\n' "$(cat minikube.sha256)" | sha256sum --check --status
    ) || die "Minikube checksum verification failed."
    as_root install -m 0755 "$download_dir/minikube" "$INSTALL_DIR/minikube"
else
    log "Minikube is already installed; leaving it unchanged"
fi

target_user="${SUDO_USER:-${USER:-}}"
if [[ -n "$target_user" && "$target_user" != "root" ]]; then
    if getent group docker >/dev/null 2>&1; then
        if ! id -nG "$target_user" | tr ' ' '\n' | grep -qx docker; then
            log "Adding ${target_user} to the docker group"
            as_root usermod -aG docker "$target_user"
            group_changed=true
        fi
    else
        die "Docker is installed, but the docker group does not exist."
    fi
fi

log "Verifying installed command-line tools"
docker --version
kubectl version --client
minikube version

printf '\nSetup complete.\n'
if [[ "${group_changed:-false}" == true ]]; then
    printf 'Log out and back in (or start a new login shell) before using Docker without sudo.\n'
fi
printf 'Start the cluster with: minikube start --driver=docker\n'
