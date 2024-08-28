defmodule Practice1.Module.Worker do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workers" do
    field :name, :string
    field :age, :integer
    field :salary, :float
    field :department_name, :string

    timestamps()
  end

  def changeset(worker, attr) do
    worker |> cast(attr, [:name, :age, :salary, :department_name]) |> validate_required([:name, :age, :salary, :department_name])
  end

end
