defmodule Practice1Web.WorkerController do
  use Practice1Web, :controller

  alias Practice1.Dbcontext.WorkerDb
  alias Practice1.Module.Worker
  alias Practice1.Sync

  def list_worker(conn, _params) do
    value = %{}
    case Sync.get_all_worker() do
      {:ok, workers} ->
        render(conn, :home, workers: workers, value: value, enter: "")

      {:error, reason} ->
        conn
        |> put_flash(:error, "Error fetching workers: #{inspect(reason)}")
        |> render(:home, workers: [], value: value, enter: "")
    end
  end

  def page_create(conn, _params) do
    changeset = Worker.changeset(%Worker{}, %{})
    render(conn, :create, changeset: changeset)
  end

  def create_worker(conn, %{"worker" => worker_param}) do
    case WorkerDb.create_worker(worker_param) do
      {:ok, _worker} ->
        # Đồng bộ dữ liệu lên elasticsearch
        Sync.sync_postgres_with_elasticsearch()

        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: ~p"/")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :create, changeset: changeset)
    end
  end

  def search(conn, %{"a" => a}) do
    value = %{"a" => a}

    case Sync.search_worker(a) do
      {:ok, workers} ->
        render(conn, :home, workers: workers, value: value, enter: a)

      {:error, reason} ->
        conn
        |> put_flash(:error, "Error fetching workers: #{inspect(reason)}")
        |> render(:home, workers: [], value: value, enter: a)
    end
  end

  # def show_detail(conn, %{"id" => id}) do
  # end

  def delete(conn, %{"id" => id}) do
    worker = WorkerDb.get_worker_id(id)

    case WorkerDb.delete_by_id(worker) do
      {:ok, _worker} ->
        Sync.sync_postgres_with_elasticsearch()
        conn
        |> put_flash(:info, "User deleted successfully.")
        |> redirect(to: ~p"/")
    end
  end
end
