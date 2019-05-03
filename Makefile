
docker-ps:
	docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}"

docker-system-df:
	docker system df
