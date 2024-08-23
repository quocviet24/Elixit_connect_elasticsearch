defmodule Practice1.Dbcontext.WorkerDb do
  alias Practice1.Module.Worker
  alias Practice1.Repo

  def create_worker(attr) do
    %Worker{}
    |> Worker.changeset(attr)
    |> Repo.insert()
  end
end
