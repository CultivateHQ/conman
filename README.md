# Conman

Elm inside Phoenix!

## Pre-requisites

Please ensure that you have [Elm installed](http://elm-lang.org/install) on your machine. You will also need to have Postgres running.


## Running the app

```bash
# get the code
git clone git@github.com:CultivateHQ/conman.git

# change directory to the project root
cd conman

# get dependencies
mix deps.get

# build and populate the database
mix ecto.create && mix ecto.migrate && mix run priv/repo/seeds.exs

# start the server
iex -S mix Phoenix.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
