defmodule SmeeOrgs.Utils do

  @moduledoc false

  alias SmeeOrgs.TldToCc

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

  def extract_domains(nowt) when nowt in [nil, "", "unspecified"] do
    []
  end

  def extract_domains("http" <> _ = url) do
    bits = URI.new!(url)
    bits.host || []
  end

  def extract_domains(urls) when is_list(urls) do
    Enum.map(urls, fn url -> extract_domains(url) end)
    |> Enum.uniq()
  end

  def extract_domains(urls) when is_map(urls) do
    Map.values(urls)
    |> Enum.map(fn url -> extract_domains(url) end)
    |> Enum.uniq()
  end

  def set_if_empty(current, possible) when is_nil(current) or current == "" or current == :unknown do
    possible
  end

  def set_if_empty(current, _possible) do
    current
  end

  def add_to_unique_list(list, item) do
    [item | list]
    |> List.flatten()
    |> Enum.sort()
    |> Enum.uniq()
  end

  def merge_lang_maps(original, new) do
    Map.merge(
      original,
      new,
      fn _k, v1, _v2 ->
        v1
      end
    )
  end

  def domain_to_country(domain) do
    TldToCc.domain_to_country(domain)
  end

end
