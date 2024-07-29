defmodule Mix.Tasks.Dump do
  use Mix.Task

  @structs_path "lib/ms2ex_file/structs/"
  @requirements ["app.start"]

  alias Ms2exFile.Redis

  @impl Mix.Task
  def run(_args) do
    Application.ensure_all_started(:myxql)

    IO.puts("Copying structs from Ms2ex.File to Ms2ex")
    File.cp_r!(@structs_path, ms2ex_path())

    IO.puts("Dumping redis database...")
    dir = Redis.dump()

    IO.puts("Dump saved: #{dir}")
  end

  defp ms2ex_path(), do: Application.fetch_env!(:ms2ex_file, :ms2ex)[:metadata_path]
end
