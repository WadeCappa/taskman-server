FROM elixir:latest

RUN mkdir /app
WORKDIR /app

COPY mix.exs mix.lock ./

RUN mix do deps.get, deps.compile

COPY . .

CMD mix ecto.create \
    && mix ecto.migrate \
    && mix run --no-halt