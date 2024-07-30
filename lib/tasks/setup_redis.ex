defmodule Mix.Tasks.Setup.Redis do
  use Mix.Task

  alias Ms2exFile.MySql
  alias Ms2exFile.Redis
  alias Ms2exFile.Data

  @requirements ["app.start"]

  @impl Mix.Task
  def run(_args) do
    Application.ensure_all_started(:myxql)

    Redis.flush()

    MySql.list_tables()
    |> Enum.map(fn [table] ->
      count = MySql.count(table)

      IO.puts("[#{table}] Reading #{count} records from MySQL...")

      primaries = MySql.get_primaries_keys(table)

      data = MySql.paginate(table, primaries, 0)
      {table, data}
    end)
    |> Map.new()
    |> Data.process()
    |> Enum.each(fn {table, data} ->
      IO.inspect("[#{table}] Caching data into redis")
      store_values(table, data)
    end)
  end

  defp store_values(table, data) do
    set = Macro.underscore(table)
    Redis.insert_sets(set, data)
  end
end
