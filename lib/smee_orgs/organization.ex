defmodule SmeeOrgs.Organization do

  alias __MODULE__
  alias SmeeOrgs.Normalize
  alias SmeeOrgs.Utils

  @type t :: %__MODULE__{
               noid: binary(),
               base_domain: nil | binary(),
               names: map(),
               displaynames: map(),
               urls: map(),
               ror: nil | binary(),
               logo_url: nil | binary(),
               location: nil | binary(),
               wikipedia: nil | binary(),
               country: nil | binary(),
               entity_uris: list(binary()),
               domains: list(binary()),
               tags: list(binary()),
               type: atom(),
               registrars: list(binary()),
               federations: list(binary())
             }

  @derive Jason.Encoder
  defstruct [
    :noid,
    :base_domain,
    :names,
    :displaynames,
    :urls,
    :ror,
    :logo_url,
    :location,
    :wikipedia,
    :country,
    entity_uris: [],
    domains: [],
    tags: [],
    type: :unknown,
    registrars: [],
    federations: []
  ]

  @spec new(name_id :: binary(), domain :: binary(), data :: map() | keyword()) :: Organization.t()
  def new(name_id, domain, data \\ %{}) do

    base_domain = Normalize.url(domain)
                  |> Normalize.base_domain()

    %Organization{
      noid: Normalize.noid(name_id),
      base_domain: base_domain,
      entity_uris: if(data[:entity_uris], do: data[:entity_uris], else: []),
      domains: if(data[:domains], do: data[:domains], else: Utils.extract_domains(data[:urls])),
      names: Normalize.lang_map(data[:names]),
      displaynames: Normalize.lang_map(data[:displaynames]),
      urls: Normalize.lang_map(data[:urls]),
      location: if(data[:location], do: data[:location], else: nil),
      logo_url: data[:logo_url],
      tags: if(data[:tags], do: data[:tags], else: []),
      ror: data[:ror],
      country: if(data[:country], do: data[:country], else: Utils.domain_to_country(base_domain)),
      type: if(data[:type], do: Normalize.type(data[:type]), else: :unknown),
      registrars: if(data[:registrars], do: data[:registrars], else: []),
      federations: if(data[:federations], do: data[:federations], else: []),
    }
    
  end

  @spec name(org :: Organization.t(), lang :: binary()) :: binary()
  def name(org, lang \\ "en") do
    Map.get(org, :names, %{})
    |> Utils.select_lang(lang)
  end

  @spec displayname(org :: Organization.t(), lang :: binary()) :: binary()
  def displayname(org, lang \\ "en") do
    Map.get(org, :displaynames, %{})
    |> Utils.select_lang(lang)
  end

  @spec url(org :: Organization.t(), lang :: binary()) :: binary()
  def url(org, lang \\ "en") do
    Map.get(org, :urls, %{})
    |> Enum.reject(fn {_k, v} -> v == "http://unspecified" end)
    |> Map.new()
    |> Utils.select_lang(lang)
  end

  @spec aggregated_text(org :: Organization.t()) :: binary()
  def aggregated_text(org) do
    [
      [org.noid],
      [org.base_domain],
      [org.country],
      org.entity_uris,
      org.domains,
      Map.values(org.names),
      Map.values(org.displaynames),
      Map.values(org.urls),
      [org.location]
    ]
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.join(" ")
  end

  @spec langs(org :: Organization.t()) :: list(binary())
  def langs(org) do
    [Map.keys(org.names), Map.keys(org.displaynames), Map.keys(org.urls)]
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort()
  end

  @spec tags(org :: Organization.t()) :: list(binary())
  def tags(org) do
    (org.tags || [])
    |> Enum.map(&to_string/1)
    |> Enum.sort()
  end

  @spec domains(org :: Organization.t()) :: list(binary())
  def domains(org) do
    (org.domains || []) ++ [org.base_domain]
    |> Enum.uniq()
    |> Enum.sort()
  end

  @spec types() :: list(atom())
  def types() do
    Normalize.types()
  end

  #########

end
