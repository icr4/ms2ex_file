defmodule Ms2exFile.Helper do
  #
  # Maps
  #

  def atomize_map_keys(map) when is_list(map) do
    Enum.map(map, &atomize_map_keys/1)
  end

  def atomize_map_keys(%NaiveDateTime{} = dt),
    do: dt

  def atomize_map_keys(map) when is_map(map) do
    Enum.map(map, fn r ->
      case r do
        {k, v} when is_binary(k) -> {atomize_key(k), atomize_map_keys(v)}
        {k, v} -> {k, atomize_map_keys(v)}
      end
    end)
    |> Map.new()
  end

  def atomize_map_keys(data), do: data

  def atomize_key(key) when is_binary(key) do
    key = field_name(key)

    case Integer.parse(field_name(key)) do
      {_, _} -> key
      _ -> String.to_atom(key)
    end
  end

  #
  # Fields
  #

  def field_name(field) when is_binary(field),
    do: field |> Macro.underscore()
end
