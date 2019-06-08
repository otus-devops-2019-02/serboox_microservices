
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

create-app-firewall-rule:
	gcloud compute firewall-rules create reddit-app \
	--allow tcp:9292 \
	--target-tags=docker-machine \
	--description="Allow PUMA connections" \
	--direction=INGRESS

docker-build:
	docker build -t serboox/post:1.0 ./src/post-py
	docker build -t serboox/comment:1.0 ./src/comment
	docker build -t serboox/ui:1.0 ./src/ui

docker-push:
	docker login
	docker push serboox/post:1.0
	docker push serboox/comment:1.0
	docker push serboox/ui:1.0

docker-rmi:
	docker rmi -f $(docker images | grep "<none>" | awk '{print $3}')

docker-run:
	docker run -d --rm --network=reddit --network-alias=post_db \
--network-alias=comment_db -v reddit_db:/data/db mongo:latest
	docker run -d --rm --network=reddit --network-alias=post serboox/post:1.0
	docker run -d --rm --network=reddit --network-alias=comment serboox/comment:1.0
	docker run -d --rm --network=reddit -p 9292:9292 serboox/ui:1.0
