defmodule Ms2exFile.Parser.Map do
  @map_entity Ms2exFile.Parser.Utils.Mapping.map_entity()

  def process_table({"map" = t, values}, tables) do
    Enum.map(values, fn map ->
      boundings = get_map_boundings(map, tables)
      pc_spawns = get_pc_spawns(map, tables)
      npc_spawns = get_npcs_spawns(map, tables)
      npcs = get_npcs(npc_spawns, tables)

      map
      |> Map.put(:boundings, boundings)
      |> Map.put(:pc_spawns, pc_spawns)
      |> Map.put(:npcs, npcs)
    end)
    |> then(&{t, &1})
  end

  defp get_map_boundings(map, tables) do
    tables
    |> Map.get("map-entity")
    |> Enum.filter(fn entity ->
      entity.block[:!] == @map_entity[:bounding] && entity.x_block == map.x_block
    end)
  end

  defp get_pc_spawns(map, tables) do
    tables
    |> Map.get("map-entity")
    |> Enum.filter(fn entity ->
      entity.block[:!] == @map_entity[:spawn_point_pc] && entity.x_block == map.x_block
    end)
  end

  defp get_npcs_spawns(map, tables) do
    tables
    |> Map.get("map-entity")
    |> Enum.filter(fn entity ->
      entity.block[:!] == @map_entity[:spawn_point_npc] && entity.x_block == map.x_block
    end)
  end

  defp get_npcs(npc_spawns, tables) do
    npc_spawns
    |> Enum.flat_map(fn entity ->
      Enum.flat_map(entity.block.npc_list, fn %{count: count, npc_id: id} ->
        Enum.map(1..count, fn _ ->
          {type, metadata} = try_get_npc_meta(id, tables)
          animation = try_get_npc_animation(metadata[:model][:name], tables)

          Map.new()
          |> Map.put(:id, id)
          |> Map.put(:spawn, normalize_npc_spawn(entity.block))
          |> Map.put(:type, type)
          |> Map.put(:metadata, metadata)
          |> Map.put(:animation, animation)
        end)
      end)
    end)
  end

  defp normalize_npc_spawn(spawn) do
    position =
      spawn.position
      |> Map.put_new(:x, 0)
      |> Map.put_new(:y, 0)
      |> Map.put_new(:z, 0)

    rotation =
      spawn
      |> Map.get(:rotation, %{})
      |> Map.put_new(:z, 0)

    spawn
    |> Map.put(:position, position)
    |> Map.put(:rotation, rotation)
  end

  defp try_get_npc_meta(actor_id, tables) do
    tables
    |> Map.get("npc")
    |> Enum.find(fn npc -> npc.id == actor_id end)
    |> case do
      nil -> {:unknown, nil}
      %{} = npc -> {:npc, npc}
    end
  end

  defp try_get_npc_animation(nil, _tables), do: nil

  defp try_get_npc_animation(model_id, tables) do
    model_id = Macro.underscore(model_id)

    tables
    |> Map.get("animation")
    |> Enum.find(fn animation -> animation.model == model_id end)
    |> case do
      nil -> nil
      %{} = anim -> anim
    end
  end
end
