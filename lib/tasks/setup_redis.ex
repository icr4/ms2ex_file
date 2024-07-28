defmodule Mix.Tasks.Setup.Redis do
  use Mix.Task

  alias Ms2exFile.Structs

  @repo :myxql
  @requirements ["app.start"]

  @impl Mix.Task
  def run(_args) do
    Application.ensure_all_started(:myxql)

    Redix.command!(:redix, ["flushdb"])
    {:ok, %MyXQL.Result{rows: tables}} = MyXQL.query(@repo, "SHOW TABLES")

    tables
    |> Enum.each(fn [t] ->
      set = t |> Structs.module_name() |> Macro.underscore()

      {:ok, %MyXQL.Result{rows: rows, num_rows: count}} =
        MyXQL.query(@repo, "SELECT * FROM `#{t}`")

      IO.inspect("[#{t}::#{set}] Read #{count} record from MySQL")

      store_values(set, t, rows)

      count = Redix.command!(:redix, ["SCARD", set])
      IO.inspect("[#{t}::#{set}] Cached #{count} results")
    end)
  end

  defp store_values(set, table, values) do
    pipeline = values |> Enum.map(&build_command(set, table, &1))
    Redix.pipeline!(:redix, pipeline)
  end

  defp build_command(set, table, value) do
    value = Structs.build(value, table)
    id_key = value.__struct__.id()
    id = Map.get(value, id_key)
    ["SADD", set, id, :erlang.term_to_binary(value)]
  end
end
