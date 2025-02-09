cd docker-supervisor
yarn up

cd ../kafka-database  
yarn up

cd ../kuma-util  
yarn up

cd ../minio-database  
yarn up

cd ../mongodb-database  
yarn up

cd ../nginx-gateway  
docker compose build
yarn up

cd ../postgres-database  
yarn up

cd ../redis-database  
yarn up

cd ../traefik-gateway
yarn up
