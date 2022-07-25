#!/bin/bash

NAMESPACE="hobbyfarm"
ADMIN_ROLE_NAME="hobbyfarm-admin"
DRY_RUN=false
OVERWRITE_ADMIN=true
ROLE_MANIFEST=role.yaml

help_menu() {
    echo 'This is the upgrade converter for HobbyFarm v2.0.0'
    echo 'This helper will migrate current "admin" users to the v2.0.0 RBAC model'
    echo 'It will create a role, "hobbyfarm-admin", and all existing admins will be rolebound to it'
    echo ''
    echo 'It is suggested to run a dry-run first to view changes that will be implemented before applying'
    echo 'This upgrade is NON-destructive. User accounts are left intact post-upgrade. All that changes'
    echo 'is the creation of RoleBindings for each admin user, and the creation of the "hobbyfarm-admin" role.'
    echo ''
    echo '-h, --help                    Display this help text'
    echo "-n, --namespace               Namespace in which HobbyFarm is installed (Default: ${NAMESPACE})"
    echo "-d, --dry-run                 Execute the script in dry-run mode, not applying changes"
    echo "-o, --overwrite-admin         Overwrite existing 'hobbyfarm-admin' role (Default: ${OVERWRITE_ADMIN})"
    exit 0;
}

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    
    case $key in
        -h|--help)
            help_menu
            shift
            shift
        ;;
        -n|--namespace)
            if [ "$2" == "" ]; then
                echo "You must provide a namespace when using -n"
                exit 1;
            fi
            NAMESPACE=$2
            shift
            shift
        ;;
        -d|--dry-run)
            if [ "$2" == "" ]; then
                echo "You must provide 'true' or 'false' when using -d"
                exit 1;
            fi
            DRY_RUN=$2
            shift
            shift
        ;;
        -o|--overwrite-admin)
            if [ "$2" == "" ]; then
                echo "You must provide 'true' or 'false' when using -o"
                exit 1;
            fi
            OVERWRITE_ADMIN=$2
            shift
            shift
        ;;
        *)
            POSITIONAL+=("$1")
            shift
        ;;
    esac
done

set -- "${POSITIONAL[@]}"
echo "
██   ██  ██████  ██████  ██████  ██    ██ ███████  █████  ██████  ███    ███
██   ██ ██    ██ ██   ██ ██   ██  ██  ██  ██      ██   ██ ██   ██ ████  ████
███████ ██    ██ ██████  ██████    ████   █████   ███████ ██████  ██ ████ ██
██   ██ ██    ██ ██   ██ ██   ██    ██    ██      ██   ██ ██   ██ ██  ██  ██
██   ██  ██████  ██████  ██████     ██    ██      ██   ██ ██   ██ ██      ██
"
echo "hobbyfarm v2.0.0 rbac converter"
echo ""
echo "Invoking with:"
echo ""
echo "Namespace:                        ${NAMESPACE}"
echo "Admin Role Name:                  ${ADMIN_ROLE_NAME}"
echo "Dry Run:                          ${DRY_RUN}"
echo "Overwrite Existing Admin Role:    ${OVERWRITE_ADMIN}"
echo "Role Manifest File:               ${ROLE_MANIFEST}"

upgrade() {
    echo 'Executing rbac converter'
    if [ "$DRY_RUN" == "true" ];
    then
        echo 'Executing in dry-run mode. No changes will be applied'
    fi
    
    check_kubernetes
    check_namespace
    check_role_manifest
    role
    check_user_crd
    rolebindings
}

role() {
    if [ "$DRY_RUN" == "true" ];
    then
        if [ "$OVERWRITE_ADMIN" == "true" ];
        then
            echo 'Dry run: would apply (overwrite: true) the following manifest:'
        else
            echo 'Dry run: would create (overwrite: false) the following manifest:'
        fi
        cat $ROLE_MANIFEST
        echo ""
    else
        if [ "$OVERWRITE_ADMIN" == "true" ];
        then
            echo 'Applying manifest (overwrite: true) to create/update hobbyfarm-admin role'
            update_role
        else
            echo 'Creating manifest (overwrite: false) to create hobbyfarm-admin role'
            create_role
        fi
    fi
}

rolebindings() {
    USERS=$(kubectl get users.hobbyfarm.io -o jsonpath='{range .items[?(@.spec.admin==true)]}{.metadata.name}{"\n"}{end}')    

    IFSBACK=$IFS
    IFS=$'\n'
    if [ "$DRY_RUN" == "true" ]; 
    then
        echo 'Dry run: would create the following role bindings:'
        for u in $USERS; do
            kubectl create rolebinding --dry-run=client -o yaml --namespace $NAMESPACE --role $ADMIN_ROLE_NAME --user $u "${u}-admin"
            echo "---"
        done
    else
        echo 'Creating rolebindings for users:'
        for u in $USERS; do
            kubectl create rolebinding --namespace $NAMESPACE --role $ADMIN_ROLE_NAME --user $u "${u}-admin"
        done
    fi
    IFS=$IFSBACK
}

check_kubernetes() {
    if ! command -v kubectl &> /dev/null
    then
        echo "kubectl not found"
        exit 1;
    fi
}

check_namespace() {
    kubectl get namespace $NAMESPACE &> /dev/null
    
    if [ $? -gt 0 ]
    then
        echo "namespace ${NAMESPACE} not found"
        exit 1;
    fi
}

check_user_crd() {
    kubectl get crd users.hobbyfarm.io &> /dev/null
    
    if [ $? -gt 0 ]
    then
        echo "users.hobbyfarm.io CRD does not exist. is there a hobbyfarm install present?"
        exit 1;
    fi
}

check_role_manifest() {
    if ! test -f "$ROLE_MANIFEST"; then
        echo "hobbyfarm-admin role manifest not found (expected $ROLE_MANIFEST)"
        exit 1;
    fi
}

create_role() {
    echo 'Creating role...'
    kubectl create role -n $NAMESPACE -f $ROLE_MANIFEST
}

update_role() {
    echo 'Creating/updating role...'
    kubectl apply -n $NAMESPACE -f $ROLE_MANIFEST
}

get_users() {
    kubectl get users -o=jsonpath='{.items[?(@.spec.admin==true)].metadata.name}'
}

while true; do
    read -p "Do you wish to run the rbac converter? (y/n)" yn
    case $yn in
        [Yy]* ) upgrade; break;;
        [Nn]* ) exit ;;
        * ) echo "Please answer y or n.";;
    esac
done