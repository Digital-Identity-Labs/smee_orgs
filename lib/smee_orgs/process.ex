defmodule SmeeOrgs.Process do

  alias SmeeOrgs.Utils
  alias SmeeOrgs.ROR

  def enhance(enum, opts \\ []) do
    Enum.map(enum, fn org -> ROR.overlay(org) end)
  end

  def uniq(enum, _opts \\ []) do
    enum
    |> Enum.uniq_by(fn org -> org.noid end)
  end

  def merge(enum, opts \\ []) do
    base_org = Enum.at(enum, 0)
    enum
    |> Enum.reduce(base_org, fn org, acc -> merge_organizations(acc, org, opts) end)
  end

  def aggregate(enum, _opts \\ []) do
    enum
    |> Enum.group_by(fn org -> org.noid end)
    |> Enum.map(fn {noid, orgs} -> merge(orgs) end)
  end

  #################

  defp merge_organizations(base, extra, _opts) do
    %{
      base |
      domains: Utils.add_to_unique_list(base.domains, extra.domains),
      names: Utils.merge_lang_maps(base.names, extra.names),
      displaynames: Utils.merge_lang_maps(base.displaynames, extra.displaynames),
      urls: Utils.merge_lang_maps(base.urls, extra.urls),
      location: Utils.set_if_empty(base.location, extra.location),
      logo_url: Utils.set_if_empty(base.logo_url, extra.logo_url),
      tags: Utils.add_to_unique_list(base.tags, extra.tags),
      ror: Utils.set_if_empty(base.ror, extra.ror),
      country: Utils.set_if_empty(base.country, extra.country),
      type: Utils.set_if_empty(base.type, extra.type),
      registrars: Utils.add_to_unique_list(base.registrars, extra.registrars),
      federations: Utils.add_to_unique_list(base.federations, extra.federations)

    }
  end

end