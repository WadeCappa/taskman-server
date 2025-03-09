FROM elixir:latest

RUN mkdir /app
WORKDIR /app

COPY mix.exs mix.lock ./

RUN mix do deps.get, deps.compile

COPY . .

EXPOSE 4002/tcp

CMD mix ecto.create \
    && mix ecto.migrate \
    && mix run --no-halt
