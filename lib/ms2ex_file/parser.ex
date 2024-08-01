defmodule Ms2exFile.Parser do
  alias Ms2exFile.Parser

  @module %{
    "map" => Parser.Map,
    "skill" => Parser.Skill
  }

  def process(tables) do
    Enum.map(tables, fn table ->
      IO.puts("Processing #{elem(table, 0)}...")
      process_table(table, tables)
    end)
  end

  defp process_table({table, _values} = arg, tables) do
    case Map.get(@module, table) do
      nil -> arg
      module -> module.process_table(arg, tables)
    end
  end
end
