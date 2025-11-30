defmodule EnneagramWeb.Answer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "answers" do
    field :answer_value, :integer
    field :answered_at, :utc_datetime

    belongs_to :test, EnneagramWeb.Test, type: :binary_id
    belongs_to :question, EnneagramWeb.Question

    timestamps(type: :utc_datetime)
  end

  def changeset(answer, attrs) do
    answer
    |> cast(attrs, [:test_id, :question_id, :answer_value, :answered_at])
    |> validate_required([:test_id, :question_id, :answer_value, :answered_at])
    |> validate_inclusion(:answer_value, 1..5)
    |> foreign_key_constraint(:test_id)
    |> foreign_key_constraint(:question_id)
    |> unique_constraint([:test_id, :question_id])
  end
end
