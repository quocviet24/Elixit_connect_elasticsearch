defmodule Practice1.Dbcontext.WorkerDb do
  alias Practice1.Module.Worker
  alias Practice1.Repo

  def create_worker(attr) do
    %Worker{}
    |> Worker.changeset(attr)
    |> Repo.insert()
  end

  def get_all_worker() do
    Repo.all(Worker)
  end

  def get_worker_id(id) do
    Repo.get!(Worker, id)
  end

  def delete_by_id(%Worker{} = worker) do
    Repo.delete(worker)
  end

  def create_workers do
    for i <- 1..10000 do
      %{
        name: "Worker #{i}",
        age: Enum.random(20..60),
        salary: Enum.random(30000..100000),
        department_name: random_department()
      }
      |> create_worker_random()
    end
  end

  defp create_worker_random(attrs) do
    %Worker{}
    |> Worker.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, _worker} ->
        IO.puts("Worker created: #{inspect(attrs)}")
      {:error, reason} ->
        IO.puts("Failed to create worker: #{inspect(reason)}")
    end
  end

  defp random_department do
    departments = [
      "Engineering",
      "Marketing",
      "Sales",
      "Human Resources",
      "Finance",
      "Customer Support"
    ]
    Enum.random(departments)
  end
end
