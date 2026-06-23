defmodule LogoTest do
  use ExUnit.Case

  alias SmeeOrgs.Logo
  alias SmeeOrgs.Organization

  @indiid_org Organization.new(
                "mimoto",
                "mimoto.co.uk",
                %{
                  displaynames: %{
                    "en" => "Mimoto"
                  },
                  names: %{
                    "en" => "Mimoto"
                  },
                  registrars: ["http://ukfederation.org.uk"],
                  urls: %{
                    "en" => "https://mimoto.co.uk"
                  },
                  logo_url: nil
                }
              )

  describe "add_site_logo_url/2" do

    test "If a logo can be found, a URL is set for logo_url in the Organization struct" do
      assert %SmeeOrgs.Organization{
               base_domain: "mimoto.co.uk",
               logo_url: "https://mimoto.co.uk/apple-touch-icon.png",
             } = Logo.add_site_logo_url(@indiid_org)
    end

    test "If a logo can't be found the struct is unchanged" do
      assert  %SmeeOrgs.Organization{
                base_domain: "example.com",
                logo_url: nil,
                noid: "mystery"
              } = Logo.add_site_logo_url(%Organization{noid: "mystery", base_domain: "example.com"})
    end

  end
  
end
