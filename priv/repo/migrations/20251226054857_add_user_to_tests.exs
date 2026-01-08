defmodule EnneagramWeb.Repo.Migrations.AddUserToTests do
  use Ecto.Migration

  def change do
    alter table(:tests) do
      add :user, :string
    end
  end
end
