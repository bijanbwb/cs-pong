# Code School Ping Pong Tracker

![Screenshot](https://cloud.githubusercontent.com/assets/201320/17226235/63d8e0a2-54d6-11e6-9c41-f1d568fd6121.png)

> Track Code School ping pong game results with Elixir and Phoenix!

## Requirements

- Erlang/OTP 19
- Elixir 1.2+
- Phoenix 1.2+
- Node 5.5.0

## Setup Instructions

1. `git clone https://github.com/codeschool/pong.git`
2. `mix deps.get` to install Phoenix dependencies.
3. `config/dev.exs` and `config/test.exs` to configure local database.
4. `mix ecto.setup` to create, migrate, and seed the database.
5. `npm install` to install Node dependencies.
6. `mix phoenix.server` to start Phoenix server.
7. `localhost:4000` to see application!

## Phoenix Console

- `iex -S mix`

## Run Tests

- `mix test`

## Contributing

Check out the [Inbox](https://github.com/codeschool/practice/issues/1) issue
to see what is currently on deck.

