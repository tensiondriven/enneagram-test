defmodule EnneagramWeb.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "questions" do
    field :text, :string
    field :category, :string
    field :t1_weight, :integer
    field :t2_weight, :integer
    field :t3_weight, :integer
    field :t4_weight, :integer
    field :t5_weight, :integer
    field :t6_weight, :integer
    field :t7_weight, :integer
    field :t8_weight, :integer
    field :t9_weight, :integer

    timestamps(type: :utc_datetime)
  end

  def changeset(question, attrs) do
    question
    |> cast(attrs, [:text, :category, :t1_weight, :t2_weight, :t3_weight, :t4_weight, :t5_weight, :t6_weight, :t7_weight, :t8_weight, :t9_weight])
    |> validate_required([:text, :category])
  end

  def weights(question) do
    %{
      1 => question.t1_weight,
      2 => question.t2_weight,
      3 => question.t3_weight,
      4 => question.t4_weight,
      5 => question.t5_weight,
      6 => question.t6_weight,
      7 => question.t7_weight,
      8 => question.t8_weight,
      9 => question.t9_weight
    }
  end
end
