defmodule SmeeOrgs.ROR do

  @moduledoc false

  alias SmeeOrgs.Normalize
  alias SmeeOrgs.Organization
  alias SmeeOrgs.Utils

  def get(org) do
    try do
      Organization.name(org)
      |> String.replace_trailing("LLC", "") # Too many Lakeland Colleges! Bug in ROR?
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

    website = website(ror)
    base_domain = if website, do: Normalize.base_domain(website), else: org.base_domain

    overlay = %{
      ror: ror.id,
      base_domain: base_domain,
      domains: Utils.add_to_unique_list(org.domains, ror.domains),
      displaynames: Utils.merge_lang_maps(org.displaynames, Normalize.lang_map(names(ror))),
      country: country(ror),
      location: location(ror),
      wikipedia: wikipedia(ror),
      type: type(ror),
      tags: Utils.add_to_unique_list(org.tags, [:ror])
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

  defp names(ror) do
    Map.get(ror, :names, [])
    |> Enum.filter(fn name -> :label in name.types end)
    |> Enum.map(fn name -> {name.lang, name.value} end)
    |> Map.new()
  end

  defp wikipedia(ror) do
    Map.get(ror, :links, [])
    |> Enum.find(%{value: nil}, fn link -> link.type == :wikipedia end)
    |> Map.get(:value)
  end

  defp website(ror) do
    Map.get(ror, :links, [])
    |> Enum.find(%{value: nil}, fn link -> link.type == :website end)
    |> Map.get(:value)
  end

end
