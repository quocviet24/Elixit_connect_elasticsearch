defmodule Practice1.Elasticsearch.Client do
  @url "http://localhost:9200"
  @username "elastic"
  @password "123456"

  def index(index, id, body) do
    url = "#{@url}/#{index}/_doc/#{id}"
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Basic #{Base.encode64("#{@username}:#{@password}")}"}
    ]
    case HTTPoison.put(url, Jason.encode!(body), headers) do
      {:ok, response} ->
        IO.inspect(response.body, label: "Elasticsearch Response Body")
        :ok
      {:error, reason} ->
        IO.inspect(reason, label: "Elasticsearch Error")
        :error
    end
  end

  def search(index, query) do
    url = "#{@url}/#{index}/_search"
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Basic " <> Base.encode64("#{@username}:#{@password}")}
    ]
    body = Jason.encode!(query)
    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        {:ok, Jason.decode!(response_body)}
      {:ok, %HTTPoison.Response{status_code: status_code, body: response_body}} ->
        {:error, %{status: status_code, body: Jason.decode!(response_body)}}
      {:error, reason} ->
        {:error, reason}
    end
  end

end
