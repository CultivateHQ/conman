# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
Conman.Repo.insert!(%Conman.Contact{name: "Bobby Tables", email: "bobby@example.com",    phone: "01 234 5678"})
Conman.Repo.insert!(%Conman.Contact{name: "Molly Apples", email: "molly@example.com",    phone: "01 789 2340"})
Conman.Repo.insert!(%Conman.Contact{name: "Elroy Bacon",  email: "el_bacon@example.com", phone: "01 398 7654"})
