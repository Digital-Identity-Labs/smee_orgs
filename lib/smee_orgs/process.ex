defmodule SmeeOrgs.Process do

  @moduledoc false

  alias SmeeOrgs.Organization
  alias SmeeOrgs.Utils
  alias SmeeOrgs.ROR
  alias SmeeOrgs.Tidy
  alias SmeeOrgs.Logo

  @spec enhance(enum :: Enumerable.t(), opts :: keyword()) :: Enumerable.t()
  def enhance(enum, opts \\ []) do
    enum
    |> Enum.map(fn org -> if opts[:tidy] == false, do: org, else: Tidy.all(org) end)
    |> Enum.map(fn org -> if opts[:ror] == false, do: org, else: ROR.overlay(org) end)
  end

  @spec uniq(enum :: Enumerable.t(), opts :: keyword()) :: Enumerable.t()
  def uniq(enum, _opts \\ []) do
    enum
    |> Enum.uniq_by(fn org -> org.noid end)
  end

  @spec merge(enum :: Enumerable.t(), opts :: keyword()) :: Enumerable.t()
  def merge(enum, opts \\ [action: :merge]) do
    base_org = Enum.at(enum, 0)
    actions = [opts[:action]]
    merged = Enum.reduce(enum, base_org, fn org, acc -> merge_organizations(acc, org, opts) end)
    %{merged | tags: Utils.add_to_unique_list(merged.tags, actions)}
  end

  @spec aggregate(enum :: Enumerable.t(), opts :: keyword()) :: Enumerable.t()
  def aggregate(enum, _opts \\ []) do
    enum
    |> Enum.group_by(fn org -> org.noid end)
    |> Enum.map(fn {_noid, orgs} -> merge(orgs, action: :aggregate) end)
  end

  @spec dump(enum :: Enumerable.t(), filename :: binary(), opts :: keyword()) :: :ok
  def dump(enum, filename, _opts \\ []) when is_list(enum) do
    File.write(filename, Jason.encode!(enum))
  end

  @spec add_logos(enum :: Enumerable.t(), opts :: keyword()) :: Enumerable.t()
  def add_logos(enum, opts \\ [force: true]) do
    enum
    |> Enum.map(fn org -> Logo.add_site_logo_url(org, opts) end)
  end

  @spec add_uris(enum :: Enumerable.t(), opts :: keyword()) :: Enumerable.t()
  def add_uris(enum, opts \\ []) do
    type = opts[:type] || :smee
    enum
    |> Enum.map(fn org -> %{org | uri: Organization.uri(org, type)} end)
  end
  
  #################

  @spec merge_organizations(base :: SmeeOrgs.Organization.t(), extra :: SmeeOrgs.Organization.t(), opts :: keyword()) :: SmeeOrgs.Organization.t()
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
      federations: Utils.add_to_unique_list(base.federations, extra.federations),
      wikipedia: Utils.set_if_empty(base.wikipedia, extra.wikipedia),
      entity_uris: Utils.add_to_unique_list(base.entity_uris, extra.entity_uris)
    }
  end

end