defmodule SmeeOrgs.Organization do

  alias __MODULE__
  alias SmeeOrgs.Normalize

  defstruct [
    :noid,
    :base_domain,
    :faux,
    :names,
    :displaynames,
    :urls,
    :ror,
    :logo_url,
    :country,
    tags: [],
    types: [],
    registrars: [],
    federations: []
  ]



  def new(name_id, domain, data) do

    %Organization{
      noid: Normalize.noid(name_id),
      base_domain: SmeeOrgs.Normalize.base_domain(domain),
      names: data[:names],
      displaynames: data[:displaynames],
      logo_url: data[:logo_url],
      tags: if(data[:tags], do: data[:tags], else: []),
      ror: data[:ror],
      country: data[:country],
      faux: if(data[:faux], do: !!data[:faux], else: false),
      types: if(data[:types], do: data[:types], else: []),
      registrars: if(data[:registrars], do: data[:registrars], else: []),
      federations: if(data[:federations], do: data[:federations], else: []),
    }

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
