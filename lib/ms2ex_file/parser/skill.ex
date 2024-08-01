defmodule Ms2exFile.Parser.Skill do
  @map_entity Ms2exFile.Parser.Utils.Mapping.map_entity()

  def process_table({"skill" = t, values}, tables) do
    Enum.map(values, fn skill ->
      additional_effects = get_additional_effects(skill, tables)

      region_skills = get_region_skills(skill, tables)

      skill
      |> Map.put(:additional_effects, additional_effects)
      |> Map.put(:region_skills, region_skills)
    end)
    |> then(&{t, &1})
  end

  defp get_additional_effects(skill, tables) do
    tables
    |> Map.get("additional-effect")
    |> Enum.filter(fn effect ->
      Enum.any?(Map.get(effect, :skills), fn s ->
        Enum.any?(Map.get(s, :skills), fn sx -> sx.id == skill.id end)
      end)
    end)
  end

  defp get_region_skills(skill, tables) do
    tables
    |> Map.get("map-entity")
    |> Enum.filter(fn entity ->
      entity.block[:!] == @map_entity[:region_skill] && entity.block.skill_id == skill.id
    end)
  end
end
