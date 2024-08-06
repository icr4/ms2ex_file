defmodule Ms2exFile.Parser.Map do
  @map_entity Ms2exFile.Parser.Utils.Mapping.map_entity()
  @mob_base_id 20_000_000

  def process_table({"map" = t, values}, tables) do
    Enum.map(values, fn map ->
      boundings = get_map_boundings(map, tables)
      pc_spawns = get_pc_spawns(map, tables)
      npc_spawns = get_npcs_spawns(map, tables)
      portals = get_portals(map, tables)
      mob_spawns = get_mob_spawns(map, tables)

      map
      |> Map.put(:boundings, boundings)
      |> Map.put(:pc_spawns, pc_spawns)
      |> Map.put(:npc_spawns, npc_spawns)
      |> Map.put(:mob_spawns, mob_spawns)
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
      entity.block[:!] in [@map_entity[:spawn_point_npc], @map_entity[:event_spawn_point_npc]] &&
        entity.x_block == map.x_block
    end)
    |> Enum.map(& &1.block)
  end

  defp get_mob_spawns(map, tables) do
    map.spawns
    |> Enum.map(fn spawn ->
      spawn_point =
        tables
        |> Map.get("map-entity")
        |> Enum.find(
          &(&1.block[:!] == @map_entity[:region_spawn] && &1.x_block == map.x_block &&
              &1.block[:id] == spawn.id)
        )

      npc_ids =
        Enum.flat_map(spawn.tags, fn tag ->
          tables
          |> Map.get("npc")
          |> Enum.filter(&(tag in &1.basic.main_tags && &1.id > @mob_base_id))
          |> Enum.map(& &1.id)
        end)
        |> Enum.uniq()

      spawn
      |> Map.put(:npc_ids, npc_ids)
      |> Map.put(:position, spawn_point[:block][:position])
      |> Map.put(:rotation, spawn_point[:block][:rotation])
    end)
    |> Enum.reject(&is_nil(&1.position))
  end
end
