#!/bin/bash

nginx_watch () {
  while inotifywait --exclude .swp -e create -e modify -e delete -e move /etc/nginx/conf.d; do
    echo "Detected Nginx Configuration Change"
    echo "Executing: nginx -s reload"
    nginx -s reload
  done
}

nginx_watch &

nginx -g "daemon off;"