defmodule Conman.Repo.Migrations.CreateContact do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add :name, :string
      add :email, :string
      add :phone, :string

      timestamps
    end

  end
end
