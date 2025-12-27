defmodule SmeeOrgs.Tidy do

  alias SmeeOrgs.Normalize
  alias SmeeOrgs.Organization
  alias SmeeOrgs.Utils

  @dfn "https://www.aai.dfn.de"

  def all(org) do
    dfn_code_names(org)
  end

  def dfn_code_names(org) do
    if Enum.member?(org.registrars, @dfn) do
      Map.put(org, :names, Map.get(org, :displaynames))
    else
      org
    end

  end


  """
      :noid,
      :base_domain,
      :faux,
      :names,
      :displaynames,
      :urls,
      :ror,
      :logo_url,
      :location,
      :wikipedia,
      :country,
      domains: [],
      tags: [],
      types: [],
      registrars: [],
      federations: []
  """

end