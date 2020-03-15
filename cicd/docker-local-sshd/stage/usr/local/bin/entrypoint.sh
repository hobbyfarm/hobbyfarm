#!/bin/sh

set -e

if ! [ -f "/etc/ssh/container-init" ]; then
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
    ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
    ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa
    ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519
    touch /etc/ssh/container-init
fi

exec "$@"
