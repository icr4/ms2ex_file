defmodule Ms2exFile.Structs do
  @structs_path "lib/ms2ex_file/structs/"
  @namespace "Ms2ex.Metadata"

  def create(table, fields) do
    path = @structs_path <> table <> ".ex"
    primaries = primary_fields(fields)
    fields = fields_list(fields)

    name = module_name(table)

    File.write!(path, module(name, fields, primaries))
  end

  def clean() do
    @structs_path
    |> File.ls!()
    |> Enum.each(&File.rm!(@structs_path <> &1))
  end

  #
  # Module
  #

  def module_name(name) do
    name |> String.replace("-", "_") |> Macro.camelize() |> then(&"#{@namespace}.#{&1}")
  end

  defp module(name, fields, primaries) do
    """
    defmodule #{name} do
      defstruct [#{Enum.join(fields, ", ")}]

      def ids(), do: [#{primaries}]
    end
    """
  end

  #
  # Fields
  #

  def field_name([name, _type, _, _primary, _, _]),
    do: field_name(name) |> then(&":#{&1}")

  def field_name(field) when is_binary(field),
    do: field |> Macro.underscore()

  def fields_list(fields) do
    fields |> Enum.map(&field_name(&1))
  end

  def primary_fields(fields) do
    fields
    |> Enum.filter(fn [_, _, _, primary, _, _] ->
      primary == "PRI"
    end)
    |> fields_list()
    |> Enum.join(", ")
  end

  #
  # Builder
  #

  def build(row, columns, table) do
    struct = Module.safe_concat([Ms2exFile.Structs.module_name(table)])
    fields = fields_list(columns)

    row =
      row
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, i}, map ->
        field = Enum.at(fields, i) |> String.to_atom()
        Map.put(map, field, atomize_map_keys(row))
      end)

    struct = struct(struct, row)

    id =
      struct.__struct__.ids()
      |> Enum.map(&Map.get(struct, &1))
      |> Enum.join("_")

    {id, struct}
  end

  defp atomize_map_keys(map) when is_list(map) do
    Enum.map(map, &atomize_map_keys/1)
  end

  defp atomize_map_keys(%NaiveDateTime{} = dt),
    do: dt

  defp atomize_map_keys(map) when is_map(map) do
    Enum.map(map, fn r ->
      case r do
        {k, v} when is_binary(k) -> {atomize_key(k), atomize_map_keys(v)}
        {k, v} -> {k, atomize_map_keys(v)}
      end
    end)
    |> Map.new()
  end

  defp atomize_map_keys(data), do: data

  defp atomize_key(key) when is_binary(key) do
    key = field_name(key)

    case Integer.parse(field_name(key)) do
      {_, _} -> key
      _ -> String.to_atom(key)
    end
  end
end
