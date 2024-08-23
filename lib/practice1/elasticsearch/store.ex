defmodule Practice1.Elasticsearch.Store do
  @behaviour Elasticsearch.Store

  alias Practice1.Repo
  alias Practice1.Elasticsearch.Client
  alias Practice1.Module.Worker

  @impl true
  def stream(schema) do
    Repo.stream(schema)
  end

  @impl true
	  def transaction(fun) do
	    {:ok, result} = Repo.transaction(fun, timeout: :infinity)
	    result
	  end

  def index_worker(%Worker{id: id, name: name, age: age, salary: salary, department_name: department_name }) do
    # chuyển đổi thành định dạng JSON
    body = %{
      "name" => name,
      "age" => age,
      "salary" => salary,
      "department_name" => department_name
    }
    index_name = "workers_index"
    Client.index(index_name, id, body)
  end
end
