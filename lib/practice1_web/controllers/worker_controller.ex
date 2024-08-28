defmodule Practice1Web.WorkerController do
  use Practice1Web, :controller

  alias Practice1.Dbcontext.WorkerDb
  alias Practice1.Module.Worker
  alias Practice1.Sync

  # def list_worker(conn, _params) do
  #   value = %{}
  #   case Sync.get_all_worker() do
  #     {:ok, workers} ->
  #       render(conn, :home, workers: workers, value: value, enter: "")

  #     {:error, reason} ->
  #       conn
  #       |> put_flash(:error, "Error fetching workers: #{inspect(reason)}")
  #       |> render(:home, workers: [], value: value, enter: "")
  #   end
  # end

  def list_worker(conn, _params) do
    case Sync.get_all_worker() do
      {:ok, workers} ->
        json(conn, %{workers: workers})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Error fetching workers", reason: inspect(reason)})
    end
  end

  def index(conn, _params) do
    workers = WorkerDb.get_all_worker()

    # Chuyển đổi dữ liệu worker thành dạng JSON
    json(conn, %{workers: Enum.map(workers, &worker_to_map/1)})
  end

  defp worker_to_map(worker) do
    %{
      id: worker.id,
      name: worker.name,
      age: worker.age,
      salary: worker.salary,
      department_name: worker.department_name,
      inserted_at: worker.inserted_at,
      updated_at: worker.updated_at
    }
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

  def show_detail(conn, %{"id" => id}) do
    case Practice1.Redis.get(id) do
      {:ok, nil} ->
        # Nếu không có dữ liệu trong Redis, tìm trong Elasticsearch
        case Sync.search_worker_id(id) do
          {:ok, worker} ->
            # Lưu dữ liệu vào Redis với thời gian hết hạn là 1 phút
            case Practice1.Redis.set(id, Jason.encode!(worker)) do
              :ok ->
                json(conn, %{worker: worker})
              {:error, reason} ->
                conn
                |> put_status(:internal_server_error)
                |> json(%{error: "Error saving to Redis", reason: inspect(reason)})
            end
          {:error, reason} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Error fetching workers from Elasticsearch", reason: inspect(reason)})
        end

      {:ok, value} ->
        # Nếu có dữ liệu trong Redis, trả về luôn
        IO.puts("Value from Redis")
        case Jason.decode(value) do
          {:ok, worker} ->
            json(conn, %{worker: worker})
          {:error, _reason} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Error decoding JSON from Redis"})
        end

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Error fetching from Redis", reason: inspect(reason)})
    end
  end

  def all_redis(conn, _params) do
    case Practice1.Redis.all_key_values() do
      {:ok, key_value_map} ->
        json(conn, %{data: key_value_map})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Error fetching data from Redis", reason: inspect(reason)})
    end
  end

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
