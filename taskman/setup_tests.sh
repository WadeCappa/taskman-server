docker run -p 5432:5432 -e POSTGRES_PASSWORD=pass -e POSTGRES_USER=postgres -d postgres
sleep 10
mix ecto.create
mix ecto.migrate
