defmodule SmeeOrgs.ROR do

  alias SmeeOrgs.Organization
  alias SmeeOrgs.Utils

  def get(org) do
    try do
      Organization.name(org)
      |> ROR.chosen_organization!() ## Bug in ROR package, need to fix then rewrite this.
    rescue
      _ -> nil
    end
  end

  def overlay(org) do
    org
    |> get()
    |> apply_ror_overlay(org)
  end

  #####################

  defp apply_ror_overlay(nil, org) do
    org
  end

  defp apply_ror_overlay(ror, org) do
    overlay = %{
      ror: ror.id,
      domains: Utils.add_to_unique_list(org.domains, ror.domains),
      country: country(ror),
      location: location(ror),
      type: type(ror),
      tags: Utils.add_to_unique_list(org.tags, [:ror, :overlay])
    }

    struct!(org, overlay)

  end

  defp location(%{locations: [%{name: name}]}) do
    name
  end

  defp location(_) do
    nil
  end

  defp country(%{locations: [%{country_code: country}]}) do
    country
  end

  defp country(_) do
    nil
  end

  defp type(%{types: types}) do

    types = List.delete(types, "funder")

    cond do
      :education in types -> :education
      :archive in types -> :archive
      :company in types -> :company
      :government in types -> :government
      :nonprofit in types -> :nonprofit
      :facility in types -> :facility
      :healthcare in types -> :healthcare
      :other in types -> :other
      true -> :unknown
    end

  end

  defp type(_) do
    :other
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