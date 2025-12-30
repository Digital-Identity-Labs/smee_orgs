defmodule SmeeOrgs.Organization do

  alias __MODULE__
  alias SmeeOrgs.Normalize
  alias SmeeOrgs.Utils

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

  def new(name_id, domain, data) do

    base_domain = SmeeOrgs.Normalize.base_domain(domain)

    %Organization{
      noid: Normalize.noid(name_id),
      base_domain: base_domain,
      entity_uris: if(data[:entity_uris], do: data[:entity_uris], else: []),
      domains: Utils.extract_domains(data[:urls]),
      names: Normalize.lang_map(data[:names]),
      displaynames: Normalize.lang_map(data[:displaynames]),
      urls: Normalize.lang_map(data[:urls]),
      location: nil,
      logo_url: data[:logo_url],
      tags: if(data[:tags], do: data[:tags], else: []),
      ror: data[:ror],
      country: if(data[:country], do: data[:country], else: Utils.domain_to_country(base_domain)),
      type: if(data[:type], do: Normalize.type(data[:type]), else: :unknown),
      registrars: if(data[:registrars], do: data[:registrars], else: []),
      federations: if(data[:federations], do: data[:federations], else: []),
    }

  end

  def name(org, lang \\ "en") do
    Map.get(org, :names, %{})
    |> Utils.select_lang(lang)
  end

  def displayname(org, lang \\ "en") do
    Map.get(org, :displaynames, %{})
    |> Utils.select_lang(lang)
  end

  def url(org, lang \\ "en") do
    Map.get(org, :urls, %{})
    |> Enum.reject(fn {k, v} -> v == "http://unspecified" end)
    |> Map.new()
    |> Utils.select_lang(lang)
  end

  def aggregated_text(org) do
    [[org.noid], [org.base_domain], [org.country], org.entity_uris, org.domains, Map.values(org.names), Map.values(org.displaynames), Map.values(org.urls), [org.location]]
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.join(" ")
  end

  def langs(org) do
    [Map.keys(org.names), Map.keys(org.displaynames), Map.keys(org.urls)]
    |> List.flatten()
    |> Enum.uniq()
  end

  def tags(org) do
    (org.tags || [])
    |> Enum.map(&to_string/1)
  end

  def domains(org) do
    (org.domains || []) ++ [org.base_domain]
    |> Enum.uniq()
  end

  def types() do
    @org_types
  end

  #########

end

## Attributes:
## - Names
## - DisplayNames
## - URLs
## - ROR
## - Other IDs
## - instanceID
## - Logo
## - Tags
## - primary_type
## - has_sps
## - has_idps
## - registrars
## - federations

##     field :name, :string
#    field :description, :string
#    field :url, :string
#    field :reg_auth, :string
#    field :displayname, :string
#    field :thumb_hash, :string, default: "PwgCBQAnL4SHh4hXiH2XVwAAAAAA"
#
#    has_many :origins, Spine.Metadata.Origin
#    has_many :destinations, Spine.Metadata.Destination
#    has_one :logo, Spine.Metadata.Logo,
#            on_replace: :delete
#
#    timestamps(type: :utc_datetime)

##      <Organization>
# 140   │         <OrganizationName xml:lang="en">Ian A. Young</OrganizationName>
# 141   │         <OrganizationDisplayName xml:lang="en">Ian A. Young</OrganizationDisplayName>
# 142   │         <OrganizationURL xml:lang="en">http://iay.org.uk/</OrganizationURL>
# 143   │     </Organization>
