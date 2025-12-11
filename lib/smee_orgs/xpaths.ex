defmodule SmeeOrgs.XPaths do

  @moduledoc false

  import Smee.Sigils

  alias SmeeLogos.Logo

  @org_xmap [
    organization_names: [
      ~x"//md:Organization/md:OrganizationName"le,
      lang: ~x"string(@xml:lang)"s,
      text: ~x"./text()"s],
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

  @spec extract_org(xdoc :: tuple()) :: map()
  def extract_org(xdoc) do
    extracted = xdoc
                |> SweetXml.xmap(@org_xmap)
    %{
      names: ml_text_map(extracted.organization_names, :text),
      displaynames: ml_text_map(extracted.organization_displaynames, :text),
      urls: ml_text_map(extracted.organization_urls, :url),
      reg_auth: extract_ra(List.first(List.wrap(extracted.registration_authority)))
    }

  end

  @spec ml_text_map(ml_list :: list(), vk :: atom()) :: map()
  defp ml_text_map(ml_list, vk) do
    ml_list
    |> Enum.map(fn h -> {h[:lang], h[vk]}  end)
    |> Map.new()
  end

  def extract_ra(%{authority: auth}) do
    auth
  end

  def extract_ra(_) do
    nil
  end

end



