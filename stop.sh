for path in *-service/; do
  service="${path%/}"
  cd $service
  echo "\n==== $service\n"
  # BEGIN

  docker compose stop
  
  # END
  cd ..
done