defmodule Practice1.Repo.Migrations.CreateWorker do
  use Ecto.Migration

  def change do
    create table("workers") do
      add :name, :string
      add :age, :integer
      add :salary, :float
      add :department_name, :string

      timestamps()
    end
  end
end
