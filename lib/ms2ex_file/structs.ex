defmodule Ms2exFile.Structs do
  @structs_path "lib/ms2ex_file/structs/"
  @namespace "Ms2ex.Metadata"

  def create(table, fields) do
    path = @structs_path <> table <> ".ex"
    {primary, fields} = fields_list(fields)
    name = module_name(table)

    File.write!(path, module(name, fields, primary))
  end

  def clean() do
    @structs_path
    |> File.ls!()
    |> Enum.each(&File.rm!(@structs_path <> &1))
  end

  def module_name(name) do
    name |> String.replace("-", "_") |> Macro.camelize() |> then(&"#{@namespace}.#{&1}")
  end

  def field_name(field),
    do: field |> Macro.underscore() |> then(&":#{&1}")

  def fields_list(fields) do
    fields =
      fields
      |> Enum.map(fn [name, _type, _, primary, _, _] ->
        %{name: field_name(name), primary: primary == "PRI"}
      end)

    primary = Enum.find(fields, & &1.primary).name
    fields = fields |> Enum.map(& &1.name) |> Enum.join(", ")

    {primary, fields}
  end

  def build(row, table) do
    struct = Module.safe_concat([Ms2exFile.Structs.module_name(table)])
    fields = struct.__struct__() |> Map.keys() |> Enum.reject(&(&1 == :__struct__))

    row =
      row
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, i}, map ->
        field = Enum.at(fields, i)
        Map.put(map, field, row)
      end)

    struct(struct, row)
  end

  defp module(name, fields, primary) do
    """
    defmodule #{name} do
      defstruct [#{fields}]

      def id(), do: #{primary}
    end
    """
  end
end
