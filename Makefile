
USER_NAME:=serboox

docker-ps:
	docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}"

docker-system-df:
	docker system df

docker-machine-gcp:
	docker-machine create --driver google \
	--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
	--google-machine-type n1-standard-1 \
	--google-zone europe-west1-b \
	docker-host

docker-machine-logging:
	docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-open-port 5601/tcp \
    --google-open-port 9292/tcp \
    --google-open-port 9411/tcp \
	--google-open-port 22/tcp \
	--google-zone europe-west1-b \
    logging

create-app-firewall-rule:
	gcloud compute firewall-rules create reddit-app \
	--allow tcp:9292 \
	--target-tags=docker-machine \
	--description="Allow PUMA connections" \
	--direction=INGRESS

docker-build:
	for folder in ui post-py comment; do \
		cd src/$$folder; \
		USER_NAME=${USER_NAME} bash docker_build.sh; \
		cd -; \
	done
	docker build -t ${USER_NAME}/prometheus ./monitoring/prometheus
	docker build -t ${USER_NAME}/alertmanager ./monitoring/alertmanager

docker-push:
	docker login --username=${USER_NAME}
	for service in ui post comment prometheus alertmanager; do \
		docker push ${USER_NAME}/$$service:latest; \
	done

docker-push-logging:
	docker login --username=${USER_NAME}
	for service in ui post comment; do \
		docker push ${USER_NAME}/$$service:logging; \
	done

docker-rmi:
	for service in ui post comment prometheus alertmanager; do \
		docker images | grep ${USER_NAME}/$$service | awk '{print $$3}' | xargs docker rmi -f; \
	done

docker-rmi-cache:
	docker rmi -f $(docker images | grep "<none>" | awk '{print $3}')

docker-run:
	docker run -d --rm --network=reddit --network-alias=post_db \
--network-alias=comment_db -v reddit_db:/data/db mongo:latest
	docker run -d --rm --network=reddit --network-alias=post serboox/post:1.0
	docker run -d --rm --network=reddit --network-alias=comment serboox/comment:1.0
	docker run -d --rm --network=reddit -p 9292:9292 serboox/ui:1.0

firewall-prometheus-allow:
	gcloud compute firewall-rules create prometheus-default --allow tcp:9090

firewall-puma-allow:
	gcloud compute firewall-rules create puma-default --allow tcp:9292

firewall-ssh-allow:
	gcloud compute firewall-rules create ssh-default --allow tcp:22

docker-compose-up:
	cd docker && docker-compose up -d
	cd docker && docker-compose -f docker-compose-monitoring.yml up -d

gcloud-create-ssh-key:
	gcloud compute ssh controller-0

kubectl-status:
	kubectl get componentstatuses

kubectl-nodes:
	kubectl get nodes

kubectl-pods:
	kubectl get pods

minikube-set-kvm:
	minikube config set vm-driver kvm2

minikube-start:
	minikube start --vm-driver kvm2

minikube-current-context:
	kubectl config current-context

minikube-context-list:
	kubectl config get-contexts

minikube-dcoker-env:
	eval $(minikube docker-env)

minikube-resolve-dns:
	minikube stop
	VBoxManage modifyvm "minikube" --natdnshostresolver1 on
	minikube start

kubectl-describe-service:
	kubectl describe service comment

# Open node port in browser
minikube-service-ui:
	minikube service ui

# Show me all opend node ports
minikube-service-list:
	minikube service list

# Show me all Kubernetes addons PODs
minikube addons list:
	minikube addons list

# Writes credentials to ~/.kube/config
gcp-kubernetes-init:
 	gcloud container clusters get-credentials your-first-cluster --zone us-central1-a --project otus-devops-235515

gcp-kubernetes-run:
	kubectl apply -f ./kubernetes/reddit/dev-namespace.yml
	kubectl apply -f ./kubernetes/reddit/ -n dev

# Get extended information about nodes
kubectl-get-nodes:
	kubectl get nodes -o wide

generate-ssl-crt:
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout kubernetes/reddit/tls.key -out kubernetes/reddit/tls.crt -subj "/CN=34.96.101.152"

kubectl-upload-crt:
 	kubectl create secret tls ui-ingress --key kubernetes/reddit/tls.key --cert kubernetes/reddit/tls.crt

kubectl-get-pv:
	kubectl get persistentvolume -n dev

helm-add-gitlab-repo:
	helm repo add gitlab https://charts.gitlab.io
	helm fetch gitlab/gitlab-omnibus --version 0.1.37 --untar

helm-install-gitlab:
	helm install --name gitlab . -f values.yaml
