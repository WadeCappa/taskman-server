FROM elixir:latest

RUN mkdir /app
WORKDIR /app

ARG DB_HOSTNAME
ENV DB_HOSTNAME=$DB_HOSTNAME

COPY mix.exs mix.lock ./

RUN mix do deps.get, deps.compile

COPY . .

EXPOSE 4001/tcp

CMD mix ecto.create \
    && mix ecto.migrate \
    && mix run --no-halt
