defmodule EnneagramWeb.Repo.Migrations.CreateTests do
  use Ecto.Migration

  def change do
    create table(:tests, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :started_at, :utc_datetime, null: false
      add :completed_at, :utc_datetime
      add :primary_type, :integer
      add :confidence, :integer
      add :scores, :map
      add :confidence_progression, :map

      timestamps(type: :utc_datetime)
    end

    create index(:tests, [:completed_at])
  end
end
