defmodule Ms2exFile.Parser.Map do
  @map_entity Ms2exFile.Parser.Utils.Mapping.map_entity()

  def process_table({"map" = t, values}, tables) do
    Enum.map(values, fn map ->
      boundings = get_map_boundings(map, tables)
      pc_spawns = get_pc_spawns(map, tables)
      npc_spawns = get_npcs_spawns(map, tables)
      portals = get_portals(map, tables)

      map
      |> Map.put(:boundings, boundings)
      |> Map.put(:pc_spawns, pc_spawns)
      |> Map.put(:npc_spawns, npc_spawns)
      |> Map.put(:portals, portals)
    end)
    |> then(&{t, &1})
  end

  defp get_portals(map, tables) do
    tables
    |> Map.get("map-entity")
    |> Enum.filter(fn entity ->
      entity.block[:!] == @map_entity[:portal] && entity.x_block == map.x_block
    end)
    |> Enum.map(& &1.block)
  end

  defp get_map_boundings(map, tables) do
    tables
    |> Map.get("map-entity")
    |> Enum.filter(fn entity ->
      entity.block[:!] == @map_entity[:bounding] && entity.x_block == map.x_block
    end)
    |> Enum.map(& &1.block)
  end

  defp get_pc_spawns(map, tables) do
    tables
    |> Map.get("map-entity")
    |> Enum.filter(fn entity ->
      entity.block[:!] == @map_entity[:spawn_point_pc] && entity.x_block == map.x_block
    end)
    |> Enum.map(& &1.block)
  end

  defp get_npcs_spawns(map, tables) do
    tables
    |> Map.get("map-entity")
    |> Enum.filter(fn entity ->
      entity.block[:!] == @map_entity[:spawn_point_npc] && entity.x_block == map.x_block
    end)
    |> Enum.map(& &1.block)
  end
end
