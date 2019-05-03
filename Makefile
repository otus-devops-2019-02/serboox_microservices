
docker-ps:
	docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}"

docker-system-df:
	docker system df

docker-mashine-gcp:
	docker-machine create --driver google \
	--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
	--google-machine-type n1-standard-1 \
	--google-zone europe-west1-b \
	docker-host

create-app-firewall-rule:
	gcloud compute firewall-rules create reddit-app \
	--allow tcp:9292 \
	--target-tags=docker-machine \
	--description="Allow PUMA connections" \
	--direction=INGRESS
