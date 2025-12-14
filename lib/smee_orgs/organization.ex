defmodule SmeeOrgs.Organization do

  alias __MODULE__
  alias SmeeOrgs.Normalize
  alias SmeeOrgs.Utils

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
      names: data[:names],
      displaynames: data[:displaynames],
      urls: data[:urls],
      location: nil,
      logo_url: data[:logo_url],
      tags: if(data[:tags], do: data[:tags], else: []),
      ror: data[:ror],
      country: data[:country],
      type: if(data[:type], do: data[:type], else: :unknown),
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
