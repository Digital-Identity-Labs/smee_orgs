defmodule SmeeOrgs.XPaths do

  @moduledoc false

  import Smee.Sigils

  alias SmeeOrgs.Utils

  @spec extract_org(entity_uri :: binary(), metadata_uri :: binary(), xdoc :: tuple()) :: map()
  def extract_org(entity_uri, metadata_uri, xdoc) do
    extracted = xdoc
                |> SweetXml.xmap(org_xmap())

    registrars = [extract_ra(List.first(List.wrap(extracted.registration_authority)))]
    federations = Utils.add_to_unique_list(registrars, [metadata_uri])

    %{
      entity_uris: [entity_uri],
      names: ml_text_map(extracted.organization_names, :text),
      displaynames: ml_text_map(extracted.organization_displaynames, :text),
      urls: ml_text_map(extracted.organization_urls, :url),
      registrars: registrars,
      federations: federations
    }

  end

  @spec ml_text_map(ml_list :: list(), vk :: atom()) :: map()
  defp ml_text_map(ml_list, vk) do
    ml_list
    |> Enum.map(fn h -> {h[:lang], h[vk]}  end)
    |> Map.new()
  end

  @spec org_xmap() :: list()
  defp org_xmap do
    [
      organization_names: [
        ~x"//md:Organization/md:OrganizationName"le,
        lang: ~x"string(@xml:lang)"s,
        text: ~x"./text()"s
      ],
      organization_displaynames: [
        ~x"//md:Organization/md:OrganizationDisplayName"le,
        lang: ~x"string(@xml:lang)"s,
        text: ~x"./text()"s
      ],
      organization_urls: [
        ~x"//md:Organization/md:OrganizationURL"le,
        lang: ~x"string(@xml:lang)"s,
        url: ~x"./text()"s
      ],
      registration_authority: [
        ~x"//md:Extensions/mdrpi:RegistrationInfo"le,
        authority: ~x"string(@registrationAuthority)"s
      ]
    ]
  end

  @spec extract_ra(map: map()) :: binary()
  def extract_ra(%{authority: auth}) do
    auth
  end

  def extract_ra(_) do
    nil
  end

end



