defmodule EnneagramWeb.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :text, :text, null: false
      add :category, :string, null: false
      add :t1_weight, :integer, null: false, default: 0
      add :t2_weight, :integer, null: false, default: 0
      add :t3_weight, :integer, null: false, default: 0
      add :t4_weight, :integer, null: false, default: 0
      add :t5_weight, :integer, null: false, default: 0
      add :t6_weight, :integer, null: false, default: 0
      add :t7_weight, :integer, null: false, default: 0
      add :t8_weight, :integer, null: false, default: 0
      add :t9_weight, :integer, null: false, default: 0

      timestamps(type: :utc_datetime)
    end
  end
end
