defmodule SmeeOrgs.Utils do

  @moduledoc false

  require Logger
  
  alias SmeeOrgs.TldToCc
  alias SmeeOrgs.Normalize

  @spec select_lang(map :: map(), lang :: binary()) :: binary() | nil
  def select_lang(map, lang \\ "en") do
    select_lang_pref(map, lang) || select_lang_default(map) || select_lang_fallback(map)
  end

  @spec select_lang_pref(map :: map(), lang :: binary()) :: binary() | nil
  def select_lang_pref(map, lang \\ "en") do
    Map.get(map, to_string(lang), nil)
  end

  @spec select_lang_default(map :: map()) :: binary() | nil
  def select_lang_default(map) do
    Map.get(map, "en", nil)
  end

  ## Maps lack ordering, so we can't simply take the first one as the default... Should we change to use lists?
  @spec select_lang_fallback(map :: map()) :: binary() | nil
  def select_lang_fallback(map) do
    Map.values(map)
    |> Enum.sort()
    |> List.first()
  end

  @spec extract_domain(url :: binary()) :: binary() | nil
  def extract_domain(nowt) when nowt in [nil, "", "unspecified", ":"] do
    nil
  end

  def extract_domain("http" <> _ = url) do
    try do
      bits = URI.new!(url)
      bits.host || nil
    rescue
      oops -> Logger.warning("Cannot parse url #{url}, returning nil (#{Exception.message(oops)})")
              nil
    end
  end
  
  def extract_domain(_) do
    nil
  end
  
  @spec extract_domains(urls :: list(binary()) | nil) :: list()
  def extract_domains(nil) do
    []
  end
  
  def extract_domains(urls) when is_list(urls) do
    Enum.map(
      urls,
      fn url ->
        Normalize.url(url)
        |> extract_domain()
      end
    )
    |> Enum.uniq()
    |> Enum.reject(&is_nil/1)
  end

  def extract_domains(urls) when is_map(urls) do
    Map.values(urls)
    |> extract_domains()
  end

  @spec set_if_empty(current :: nil | binary() | :unknown, possible :: nil | binary() | :unknown) :: binary() | nil | :unknown
  def set_if_empty(current, possible) when is_nil(current) or current == "" or current == :unknown or current == "ZZ" do
    possible
  end

  def set_if_empty(current, _possible) do
    current
  end

  @spec add_to_unique_list(list :: list(), item :: binary() | nil | atom() | list()) :: list()
  def add_to_unique_list(list, item) do
    [item | list]
    |> List.flatten()
    |> Enum.sort()
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  @spec merge_lang_maps(original :: map(), new :: map()) :: map()
  def merge_lang_maps(original, new) do
    Map.merge(
      original,
      new,
      fn _k, v1, _v2 ->
        v1
      end
    )
  end

  @spec domain_to_country(domain :: binary()) :: binary()
  def domain_to_country(domain) do
    TldToCc.domain_to_country(domain)
  end
  
end
