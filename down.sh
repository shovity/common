for path in *-service/; do
  service="${path%/}"
  cd $service
  echo "\n==== $service\n"
  # BEGIN

  yarn down
  
  # END
  cd ..
done