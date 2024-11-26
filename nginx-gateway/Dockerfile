FROM nginx:1.27.2-alpine

RUN apk add inotify-tools

COPY ./docker-entrypoint.sh .
COPY ./conf.d /etc/nginx/
COPY ./nginx.conf /etc/nginx/

ENTRYPOINT ["sh", "./docker-entrypoint.sh"]