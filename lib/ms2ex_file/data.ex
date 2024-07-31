defmodule Ms2exFile.Data do
  @map_entity %{
    :region_skill => 821_242_714,
    :trigger_skill => 737_806_629,
    :bounding => 1_539_875_768,
    :spawn_point_pc => 476_587_788,
    :spawn_point_npc => 207_007_606
  }

  def process(tables) do
    Enum.map(tables, fn table ->
      IO.puts("Processing #{elem(table, 0)}...")
      process_table(table, tables)
    end)
  end

  defp process_table({"skill" = t, values}, tables) do
    Enum.map(values, fn skill ->
      additional_effects =
        tables
        |> Map.get("additional-effect")
        |> Enum.filter(fn effect ->
          Enum.any?(Map.get(effect, :skills), fn s ->
            Enum.any?(Map.get(s, :skills), fn sx -> sx.id == skill.id end)
          end)
        end)

      region_skills =
        tables
        |> Map.get("map-entity")
        |> Enum.filter(fn entity ->
          entity.block[:!] == @map_entity[:region_skill] && entity.block.skill_id == skill.id
        end)

      skill
      |> Map.put(:additional_effects, additional_effects)
      |> Map.put(:region_skills, region_skills)
    end)
    |> then(&{t, &1})
  end

  defp process_table({"map" = t, values}, tables) do
    Enum.map(values, fn map ->
      boundings =
        tables
        |> Map.get("map-entity")
        |> Enum.filter(fn entity ->
          entity.block[:!] == @map_entity[:bounding] && entity.x_block == map.x_block
        end)

      pc_spawns =
        tables
        |> Map.get("map-entity")
        |> Enum.filter(fn entity ->
          entity.block[:!] == @map_entity[:spawn_point_pc] && entity.x_block == map.x_block
        end)

      npc_spawns =
        tables
        |> Map.get("map-entity")
        |> Enum.filter(fn entity ->
          entity.block[:!] == @map_entity[:spawn_point_npc] && entity.x_block == map.x_block
        end)

      map
      |> Map.put(:boundings, boundings)
      |> Map.put(:pc_spawns, pc_spawns)
      |> Map.put(:npc_spawns, npc_spawns)
    end)
    |> then(&{t, &1})
  end

  defp process_table({table, values}, _tables), do: {table, values}
end
