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
end
