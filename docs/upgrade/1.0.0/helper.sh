#!/bin/bash

#####################
# jgoebel@SVA, 2021 #
#####################

NAMESPACE="hobbyfarm"
HELM_RELEASE="hf"
BACKUP_FOLDER="./backup"
VALUES_PATH="values.yml"
CHART_REPO="https://hobbyfarm.github.io/hobbyfarm"

RESOURCES='users courses scenarios environments virtualmachinetemplates scheduledevents' #Resources to be backupped
RESOURCES_NAMESPACED='modules' #Resources to be backuped that are already namespaced
CRDS_RANCHER='virtualmachines settings machineimages credentials arptables' #CRDs in ranchers scope
CRDS_HOBBYFARM='accesscodes courses dynamicbindconfigurations dynamicbindrequests environments scenarios scheduledevents sessions users virtualmachineclaims virtualmachinesets virtualmachinetemplates virtualmachines' #CRDs in hf scope
CRDS_TERRAFORM='executions modules states' #CRDs in terraform scope
REMOVE_FINALIZERS='virtualmachines' # Remove finalizers from this resources
REMOVE_FINALIZERS_NAMESPACED='states executions modules' # Remove finalizers from this namespaced resources

ONLY_UNINSTALL="no"

help_menu () {
   echo 'This is the upgrade helper for hobbyfarm 1.0.0'
   echo 'The helper will backup the current hobbyfarm release and tries to roll out the new multi instance cluster functionality'
   echo 'You can set different attributes to change the helpers behaviour:'
   echo ''
   echo '-h, --help            Display this help text'
   echo "-n, --namespace       Helm release namespace (Default: ${NAMESPACE})"
   echo "-r, --release         Helm release name (Default: ${HELM_RELEASE})"
   echo "-b, --backup-folder   Folder where the backup should be saved (Default: ${BACKUP_FOLDER})"
   echo "-v, --values          Path to values.yml (Default: ${VALUES_PATH})"
   echo "-c, --repo            URL to chart repository (Default: ${CHART_REPO})"
   echo "-u, --uninstall	   Only unistall the current hobbyfarm release and remove all CRDs"
   exit 0;
}

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -h|--help)
      help_menu
	  shift # past argument
      shift # past value
      ;;
    -n|--namespace)
      NAMESPACE="$2"
      shift # past argument
      shift # past value
      ;;
    -r|--release)
      HELM_RELEASE="$2"
      shift # past argument
      shift # past value
      ;;
	-b|--backup-folder)
      BACKUP_FOLDER="$2"
      shift # past argument
      shift # past value
      ;;
    -v|--values)
      VALUES_PATH="$2"
      shift # past argument
      shift # past value
      ;;
	-c|--repo)
      CHART_REPO="$2"
      shift # past argument
      shift # past value
      ;;
    -u|--uninstall)
      ONLY_UNINSTALL="yes"
      shift # past argument
      ;;
    *)    # unknown option
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters
echo "
██   ██  ██████  ██████  ██████  ██    ██ ███████  █████  ██████  ███    ███ 
██   ██ ██    ██ ██   ██ ██   ██  ██  ██  ██      ██   ██ ██   ██ ████  ████ 
███████ ██    ██ ██████  ██████    ████   █████   ███████ ██████  ██ ████ ██ 
██   ██ ██    ██ ██   ██ ██   ██    ██    ██      ██   ██ ██   ██ ██  ██  ██ 
██   ██  ██████  ██████  ██████     ██    ██      ██   ██ ██   ██ ██      ██
"
echo "hobbyfarm 1.0.0 Upgrade helper"
echo ""
echo "using variables:"
echo "HELM NAMESPACE    = ${NAMESPACE}"
echo "HELM RELEASE NAME = ${HELM_RELEASE}"
echo "BACKUP FOLDER     = ${BACKUP_FOLDER}"
echo "VALUES PATH       = ${VALUES_PATH}"
echo "CHART REPOSITORY  = ${CHART_REPO}"
echo "ONLY UNINSTALL    = ${ONLY_UNINSTALL}"
echo ""
echo "see -h or --help for a overview on variables"
echo ""
echo "Upgrade will back up and restore: ${RESOURCES}"

#Print simple seperator line that fills the full width
seperator(){
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
} 

#the main method for our upgrade process
upgrade(){
	seperator
	
	
	if [ "$ONLY_UNINSTALL" == "yes" ]; then
		echo "Ok. We will uninstall hobbyfarm now."
		patch_all
		uninstall_release
		delete_crds
	else
		echo "Ok. We will try to upgade hobbyfarm now."
		backup
		patch_all
		uninstall_release
		delete_crds
		reinstall_release
		apply_resources
		
		seperator
		finish
	fi

}

# backup resource into yaml file
# $1	Resource to backup
# $2    Namespace of resource
backup_resource(){
    local ns=""
	if [ -n "$2" ]; then
	  ns=" -n $2 "
	fi
	
	echo "Backup $1 into ${BACKUP_FOLDER}/$1.yml"
	kubectl get $1 $ns -o yaml > $BACKUP_FOLDER/$1.yml
	echo "Successfully backed up $1"
}

# backup all resources
backup(){
	seperator
	echo "First we create a backup from the existing hobbyfarm instance."
	
	if [ -d "${BACKUP_FOLDER}" ]; then
		read -p "Seems like a backup in ${BACKUP_FOLDER} already exists. Override? (y/N)" yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) return;;
			* ) echo "Please answer yes or no.";;
		esac
	fi
	
	echo "Ensure directory exists: ${BACKUP_FOLDER}"
	mkdir -p $BACKUP_FOLDER
	
	for i in $RESOURCES; do
		backup_resource $i
	done
	
	for i in $RESOURCES_NAMESPACED; do
		backup_resource $i $NAMESPACE
	done
}

# patches all resources for a given crd to remove all finalizers on them.
# $1 	CRD to patch
# $2	Namespace of resources, if none given cluster scope is used
patch_crd(){
	local ns=""
	if [ -n "$2" ]; then
	  ns=" -n $2 "
	fi

	echo "Trying to remove finalizers on $1"
	kubectl get $1 $ns -o name | sed -e 's/.*\///g' | xargs -I {} kubectl patch $1 $ns {} --type=json -p='[{"op": "replace", "path": "/metadata/finalizers", "value": []}]'
	echo "Removed finalizers from $1"
}

# delete a crd in a given scope
# $1 CRD 
# $2 scope
delete_crd(){
	echo "trying to delete CRD $1.$2"
	kubectl delete crd $1.$2
	echo "deleted CRD $1.$2"
}

# delete all crds from hobbyfarm release
delete_crds(){
	seperator
	echo "Trying to delete all CRDs"
	for i in $CRDS_RANCHER; do
		delete_crd $i "vm.rancher.io"
	done
	for i in $CRDS_HOBBYFARM; do
		delete_crd $i "hobbyfarm.io"
	done
	for i in $CRDS_TERRAFORM; do
		delete_crd $i "terraformcontroller.cattle.io"
	done
}

# remove finalizers from all resources that provide one
patch_all(){
	seperator
	echo "Also we will try to patch some resources that could block the upgrade process"
	for i in $REMOVE_FINALIZERS; do
		patch_crd $i
	done
	
	for i in $REMOVE_FINALIZERS_NAMESPACED; do
		patch_crd $i $NAMESPACE
	done
}

#uninstall helm release
uninstall_release(){
	seperator
	echo "Next we will uninstall the hobbyfarm release"
	helm uninstall $HELM_RELEASE -n $NAMESPACE
}

# install new hobbyfarm release
reinstall_release(){
	seperator
	echo "Trying to reinstall hobbyfarm release"
	helm upgrade --install $HELM_RELEASE hobbyfarm --repo $CHART_REPO --namespace $NAMESPACE -f $VALUES_PATH
}

apply_resource(){
	kubectl apply -n $NAMESPACE -f $BACKUP_FOLDER/$1.yml
}

# apply all resources back to cluster
apply_resources(){
	seperator
	echo "Last we will restore the resources into the new hobbyfarm instance"
	
	for i in $RESOURCES; do
		apply_resource $i
	done
	
	for i in $RESOURCES_NAMESPACED; do
		apply_resource $i
	done
}

finish(){
	echo "Upgrade complete. Happy farming!"
	seperator
	echo "Upgrade the new cluster with:"
	echo "helm upgrade --install ${HELM_RELEASE} hobbyfarm --repo ${CHART_REPO} --namespace ${NAMESPACE} -f ${VALUES_PATH}"
	echo ""
}

while true; do
    read -p "Do you wish to run the upgrade helper? (y/N)" yn
    case $yn in
        [Yy]* ) upgrade; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done