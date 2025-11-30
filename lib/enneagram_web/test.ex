defmodule EnneagramWeb.Test do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "tests" do
    field :started_at, :utc_datetime
    field :completed_at, :utc_datetime
    field :primary_type, :integer
    field :confidence, :integer
    field :scores, :map
    field :confidence_progression, :map

    has_many :answers, EnneagramWeb.Answer

    timestamps(type: :utc_datetime)
  end

  def changeset(test, attrs) do
    test
    |> cast(attrs, [:started_at, :completed_at, :primary_type, :confidence, :scores, :confidence_progression])
    |> validate_required([:started_at])
  end

  def complete_changeset(test, attrs) do
    test
    |> changeset(attrs)
    |> validate_required([:completed_at, :primary_type, :confidence, :scores])
  end
end
