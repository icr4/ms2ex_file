defmodule Mix.Tasks.Setup.Redis do
  use Mix.Task

  alias Ms2exFile.Structs
  alias Ms2exFile.MySql
  alias Ms2exFile.Redis

  @requirements ["app.start"]

  @impl Mix.Task
  def run(_args) do
    Application.ensure_all_started(:myxql)

    Redis.flush()

    MySql.list_tables()
    |> Enum.each(fn [table] ->
      set = table |> Structs.module_name() |> Macro.underscore()
      count = MySql.count(table)

      IO.puts("[#{table}:#{set}] Reading #{count} records from MySQL...")

      primaries = MySql.get_primaries_key(table)

      MySql.paginate(table, primaries, 0, fn columns, rows ->
        store_values(set, table, columns, rows)
      end)

      IO.puts("[#{table}:#{set}] Cached #{Redis.count_structs(set)} into Redis")
    end)
  end

  defp store_values(set, table, columns, values) do
    values
    |> Enum.map(&Structs.build(&1, columns, table))
    |> Redis.insert_structs(set)
  end
end
