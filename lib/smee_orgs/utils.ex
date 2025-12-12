defmodule SmeeOrgs.Utils do

  def select_lang(map, lang \\ "en") do
    select_lang_pref(map, lang) || select_lang_default(map) || select_lang_fallback(map)
  end

  def select_lang_pref(map, lang \\ "en") do
    Map.get(map, to_string(lang), nil)
  end

  def select_lang_default(map) do
    Map.get(map, "en", nil)
  end

  def select_lang_fallback(map) do
    Map.values(map)
    |> List.first()
  end

  def add_to_unique_list(list, item) do
    [item | list]
    |> List.flatten()
    |> Enum.sort()
    |> Enum.uniq()
  end

end
