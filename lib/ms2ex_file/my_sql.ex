defmodule Ms2exFile.MySql do
  @repo :myxql
  @page_size 2000

  alias Ms2exFile.Helper

  def list_tables() do
    {:ok, %MyXQL.Result{rows: tables}} = MyXQL.query(@repo, "SHOW TABLES")

    tables
  end

  def list_columns(table) do
    {:ok, %MyXQL.Result{rows: fields}} = MyXQL.query(@repo, "SHOW COLUMNS FROM `#{table}`")

    fields
  end

  def get_primaries_keys(table) do
    table
    |> list_columns()
    |> Enum.filter(fn [_, _, _, primary, _, _] ->
      primary == "PRI"
    end)
  end

  def get_primaries_key_for_query(primaries) do
    primaries
    |> Enum.map(&("`#{hd(&1)}`" <> " ASC"))
    |> Enum.join(", ")
  end

  def get_primaries_key_for_set(primaries) do
    primaries
    |> Enum.map(&Helper.atomize_key(hd(&1)))
  end

  def count(table) do
    {:ok, %MyXQL.Result{rows: [[count]]}} =
      MyXQL.query(@repo, "SELECT COUNT(*) FROM `#{table}`")

    count
  end

  def paginate(table, primaries, offset, data \\ []) do
    {:ok, %MyXQL.Result{columns: columns, rows: rows, num_rows: count}} =
      MyXQL.query(
        @repo,
        "SELECT * FROM `#{table}` ORDER BY #{get_primaries_key_for_query(primaries)} LIMIT #{@page_size} OFFSET #{offset}"
      )

    data = data ++ map_results(columns, get_primaries_key_for_set(primaries), rows)

    if count < @page_size,
      do: data,
      else: paginate(table, primaries, offset + @page_size, data)
  end

  defp map_results(columns, primaries, rows) do
    Enum.map(rows, fn row ->
      map =
        row
        |> Enum.with_index()
        |> Enum.map(fn {data, i} ->
          {
            Helper.atomize_key(Enum.at(columns, i)),
            Helper.atomize_map_keys(data)
          }
        end)
        |> Map.new()

      Map.put(map, :redis_id, redis_id(primaries, map))
    end)
  end

  defp redis_id(primaries, map) do
    fields = Enum.map(primaries, &Map.get(map, &1))

    Enum.join(fields, "_")
  end

  def parse_uri(uri) do
    with %URI{} = uri <- URI.parse(uri),
         false <- nil_uri?(uri),
         {:scheme, "mysql"} <- {:scheme, uri.scheme},
         {:credentials, [username, password]} <- {:credentials, String.split(uri.userinfo, ":")} do
      database = String.replace(uri.path, "/", "")

      [
        hostname: uri.host,
        username: username,
        password: password,
        database: database,
        port: uri.port,
        timeout: :infinity
      ]
    else
      {:scheme, scheme} ->
        raise "MySQL URI error: invalid scheme #{scheme}, only `mysql` is allowed"

      {:credentials, _} ->
        raise "MySQL URI error: invalid username or password, use `username:password` as format"

      _ ->
        raise "MySQL URI error: ensure `ms2ex_file` is properly configured in your `config.exs` file"
    end
  end

  defp nil_uri?(%URI{} = uri) do
    uri
    |> Map.take([:scheme, :userinfo, :host, :port, :path])
    |> Enum.any?(&is_nil(elem(&1, 1)))
  end
end
