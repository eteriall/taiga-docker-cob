 exec docker compose -f docker-compose.yml -f docker-compose.penpot.yml up -d --scale nginx-ssl-get=0 --scale certbot=0

