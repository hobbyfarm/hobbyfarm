#!/bin/sh -e

cd $(dirname $0)

build="false"
import_images="false"
script="$0"
seed_data="true"

# when --import-images is set
# load hobbyfarm and kube-system images from docker
# this is useful on slow networks
hf_images='
    hobbyfarm/terraform-controller:12032019
    oats87/terraform-controller-executor:hfv1
'
k3d_images='
    coredns/coredns:1.6.3
    rancher/klipper-helm:v0.2.3
    rancher/klipper-lb:v0.1.2
    rancher/metrics-server:v0.3.6
    rancher/local-path-provisioner:v0.0.11
    traefik:1.7.19
'

wait_secret() {
    ready="0"
    for i in $(seq 1 $1); do
        ready=$(docker exec hf-k3d \
            kubectl -n "$2" get secret -o name | grep "$3" | wc -l)
        
        if [ "$ready" != "0" ]; then
            break
        fi
        echo "waiting for ns:${2} secret:${3} to be ready: ${i}s"
        sleep 1
    done
    if [ "$ready" = "0" ]; then
        echo "ns:${2} secret:${3} not ready after ${1} seconds" >&2
        exit 1
    fi
}

wait_deployment() {
    ready="0"
    for i in $(seq 1 $1); do
        ready=$(docker exec hf-k3d \
            kubectl -n "$2" get deployment "$3" -o 'jsonpath={.status.readyReplicas}')
        ready="${ready:-0}"
        if [ "$ready" != "0" ]; then
            break
        fi
        echo "waiting for ns:${2} deployment:${3} to be ready: ${i}s"
        sleep 1
    done
    if [ "$ready" = "0" ]; then
        echo "ns:${2} deployment:${3} not ready after ${1} seconds" >&2
        echo "if you are on a slow network, consider importing images from docker:" >&2
        echo "" >&2
        echo "   $script up --import-images" >&2
        echo "" >&2
        exit 1
    fi
}

up_usage() {
cat >&2 <<EOF
start k3d

    usage: $script up <options>

options:
        --build          - build new container
    -h, --help           - print this message
        --import-images  - import hobbyfarm and k3d system images from docker
        --no-seed-data   - do not seed hobbyfarm data on first-run

EOF
}

up() {
    while test $# -gt 0
    do
        case "$1" in
            -h | --help)
                up_usage
                exit 0
                ;;
            --build)
                build="true"
                ;;
            --import-images)
                import_images="true"
                ;;
            --no-seed-data)
                seed_data="false"
                ;;
            *)
                up_usage
                exit 1
                ;;
        esac
        shift
    done

    # ensure compose.resolv.conf exists
    if ! [ -f cicd/k3d.resolv.conf ]; then
        cp cicd/k3d.resolv.conf.example cicd/k3d.resolv.conf
    fi

    # create docker network "hobbyfarm-dev"
    if ! docker network inspect hobbyfarm-dev >/dev/null 2>&1; then
        docker network create hobbyfarm-dev
    fi

    # create docker volume "hobbyfarm-kube-sa"
    if ! docker volume inspect hobbyfarm-kube-sa >/dev/null 2>&1; then
        docker volume create hobbyfarm-kube-sa
    fi

    # start docker-compose
    if ! docker inspect hf-k3d >/dev/null 2>&1; then
        build="true"
    fi
    if [ "$build" = "true" ]; then
        echo "cleaning old docker-compose stack if one exists" >&2
        docker-compose down -v

        echo "building docker-compose stack" >&2
        echo "" >&2
        docker-compose up -d -V --build
    else
        echo "starting existing docker-compose stack" >&2
        echo "to recreate with updated containers, run:" >&2
        echo "" >&2
        echo "   $script up --build" >&2
        echo "" >&2
        echo "" >&2
        docker-compose start
    fi

    # set first-run status
    first_run_do="true"
    if docker exec hf-k3d sh -c '[ -f "/etc/first-run-complete" ]'; then
        first_run_do="false"
    fi

    # wait for default namespace to be ready
    echo "" >&2
    echo "waiting for default namespace to be ready" >&2
    wait_secret "120" "default" "default-token"

    if [ "$import_images" = "true" ]; then
        # pause kube-system deployments
        echo "" >&2
        echo "pausing kube-system deployments" >&2
        docker exec hf-k3d sh -c '
            kubectl -n kube-system get deploy -o name \
                | xargs kubectl -n kube-system scale --replicas=0
        '
    fi

    # apply CRDs
    echo "" >&2
    echo "applying CRDs" >&2
    docker exec hf-k3d \
        kubectl apply -f /app/charts/hobbyfarm/crds/

    # actions on first-run
    if [ "$first_run_do" = "true" ]; then
        echo "" >&2
        echo "performing first-run actions" >&2

        # copy service account token on first-run
        echo "" >&2
        echo "copying service account token" >&2
        docker exec hf-k3d sh -c '
                cd /var/run/secrets/kubernetes.io/serviceaccount
                secret=$(kubectl get secret \
                        -o name  \
                    | grep "default-token")
                kubectl get "$secret" \
                    -o "jsonpath={.data.ca\.crt}" \
                    | base64 -d \
                    > ca.crt
                kubectl get "$secret" \
                    -o "jsonpath={.data.namespace}" \
                    | base64 -d \
                    > namespace
                kubectl get "$secret" \
                    -o "jsonpath={.data.token}" \
                    | base64 -d \
                    > token
            '

        echo "" >&2
        echo "building development images" >&2
        docker-compose -f cicd/docker-compose-local.yaml build

        # import sshd
        echo "" >&2
        echo "importing sshd" >&2
        docker image save hobbyfarm/local-sshd:latest \
            | docker exec -i hf-k3d ctr image import -

        # import tf-git
        echo "" >&2
        echo "importing tf-git" >&2
        docker image save hobbyfarm/local-tf-git:latest \
            | docker exec -i hf-k3d ctr image import -

        if [ "$import_images" = "true" ]; then
            # import kube-system images
            for image in $hf_images $k3d_images; do
                echo "" >&2
                echo "importing $image" >&2
                if ! docker image inspect "$image" >/dev/null 2>&1; then
                    docker pull "$image"
                fi
                docker image save "$image" \
                    | docker exec -i hf-k3d ctr image import -
            done

            # resume kube-system deployments
            echo "" >&2
            echo "resuming kube-system deployments" >&2
            docker exec hf-k3d sh -c '
                kubectl -n kube-system get deploy -o name \
                    | xargs kubectl -n kube-system scale --replicas=1
            '
        fi

        # wait for coredns to be ready
        echo "" >&2
        echo "waiting for coredns to be ready" >&2
        wait_deployment "300" "kube-system" "coredns"

        # apply infrastructure-related resources
        echo "" >&2
        echo "applying infrastructure-related resources" >&2
        docker exec hf-k3d \
            kubectl apply -f /app/cicd/seed-infra/

        # wait for dev services to be ready
        echo "" >&2
        echo "waiting dev services to be ready" >&2
        wait_deployment "60" "default" "sshd"
        wait_deployment "60" "default" "tf-git"
        wait_deployment "300" "default" "terraform-controller"

        # seed data
        if [ "$seed_data" = "true" ]; then
            echo "" >&2
            echo "applying seed data" >&2
                data_seed
        fi

        echo "" >&2
        echo "first-run actions complete" >&2
        docker exec hf-k3d touch "/etc/first-run-complete"
    fi

    echo "" >&2
    echo "docker-compose stack has started" >&2
    echo "" >&2
}

stop() {
    docker-compose stop
}

destroy() {
    docker-compose down -v
}

data_clear() {
    # clear all hobbyfarm crd instances
    docker exec hf-k3d sh -c '
            set -e pipefail
            kubectl get crd \
                | grep -F hobbyfarm.io \
                | cut -d" " -f1 \
                | xargs \
                | tr " " "," \
                | xargs kubectl get --all-namespaces -o name \
                | xargs -r kubectl delete
        '
}

data_seed() {
    # apply local seed data
    docker exec hf-k3d \
        kubectl apply -f /app/cicd/seed-data/
}

get_kubeconfig() {
    docker exec -it hf-k3d sh -c '
        kubectl config view --raw \
            | sed "s/127\.0\.0\.1:6443/localhost:${K3D_PORT}/g"
    '
}

shell() {
    docker exec -it hf-k3d sh
}

usage() {
cat >&2 <<-EOF
manage local HobbyFarm development environment

        usage: $script <options> <command>
        
where <command> is one of:

    up          - create or start k3d
    stop        - stop k3d
    destroy     - destroy k3d
    seed        - reseed k3d with CRD instances
    clear       - clear all CRD instances
    shell       - drop a shell into k3d container

options:
    -h, --help  - print this message

EOF
}

case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    up)
        shift
        up "$@"
        ;;
    stop)
        stop
        ;;
    destroy)
        destroy
        ;;
    kubeconfig)
        get_kubeconfig
        ;;
    seed)
        data_seed
        ;;
    clear)
        data_clear
        ;;
    shell)
        shell
        ;;
    *)
        usage
        exit 1
        ;;
esac
