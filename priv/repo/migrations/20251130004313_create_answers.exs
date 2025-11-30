defmodule EnneagramWeb.Repo.Migrations.CreateAnswers do
  use Ecto.Migration

  def change do
    create table(:answers) do
      add :test_id, references(:tests, type: :uuid, on_delete: :delete_all), null: false
      add :question_id, references(:questions, on_delete: :restrict), null: false
      add :answer_value, :integer, null: false
      add :answered_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:answers, [:test_id])
    create index(:answers, [:question_id])
    create unique_index(:answers, [:test_id, :question_id])
  end
end
