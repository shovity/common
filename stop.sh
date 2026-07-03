for path in */; do
  service="${path%/}"
  ( cd "$service" || exit
    printf '\n==== %s\n' "$service"
    # BEGIN
    docker compose stop
    # END
  )
done