defmodule OrganizationTest do
  use ExUnit.Case

  alias SmeeOrgs.Organization


  @cern_org %Organization{
    base_domain: "cern.ch",
    country: "CH",
    displaynames: %{
      "de" => "Europäische Organisation für Kernforschung",
      "en" => "CERN",
      "fr" => "Organisation européenne pour la recherche nucléaire"
    },
    domains: ["cern.ch", "www.cern.ch"],
    entity_uris: [
      "https://edugain-sp-dev.web.cern.ch/saml2sp/saml2_backend.xml",
      "https://edugain-sp-qa.web.cern.ch/saml2sp/saml2_backend.xml",
      "https://sp-proxy.cern.ch/saml2sp/saml2_backend.xml"
    ],
    federations: ["http://rr.aai.switch.ch/", "http://ukfederation.org.uk"],
    location: "Geneva",
    names: %{
      "en" => "cern.ch",
      "fr" => "CERN"
    },
    noid: "cernch",
    registrars: ["http://rr.aai.switch.ch/"],
    ror: "https://ror.org/01ggx4157",
    tags: [:ror],
    type: :facility,
    urls: %{
      "en" => "http://www.cern.ch/",
      "fr" => "http://www.cern.ch/#french"
    },
    wikipedia: "https://en.wikipedia.org/wiki/CERN"
  }

  @indiid_data %{
    displaynames: %{
      "en" => "Indiid"
    },
    entity_uris: ["https://indiid.net/idp/shibboleth"],
    federations: ["http://example.com/federation", "http://ukfederation.org.uk"],
    names: %{
      "en" => "Digital Identity Ltd"
    },
    registrars: ["http://ukfederation.org.uk"],
    urls: %{
      "en" => "https://indiid.net/"
    }
  }

  describe "new/3" do

    test "will return a minimal, useless Organization record with only the first two params" do

      assert %SmeeOrgs.Organization{
               noid: "test_org",
               base_domain: "test.org"
             } = Organization.new("test_org", "test.org")

    end

    test "domains are normally extracted from the XML info" do
      assert %Organization{domains: ["indiid.net"]} = Organization.new("digital_identity", "indiid.net", @indiid_data)
    end

    test "but domains can also be set directly" do
      assert %Organization{domains: ["digitalidentitylabs.com"]} = Organization.new(
               "digital_identity",
               "indiid.net",
               Map.put(@indiid_data, :domains, ["digitalidentitylabs.com"])
             )
    end

    test "Location can be set directly" do
      assert %Organization{location: "Manchester"} = Organization.new(
               "digital_identity",
               "indiid.net",
               Map.put(@indiid_data, :location, "Manchester")
             )

    end

    test "country can be extracted from the domain name, if possible" do
      assert %Organization{country: "GB"} = Organization.new(
               "digital_identity",
               "digitalidentitylabs.co.uk",
               Map.put(@indiid_data, :domains, ["digitalidentitylabs.com"])
             )

    end

    test "country can be set directly" do
      assert %Organization{country: "GB"} = Organization.new(
               "digital_identity",
               "digitalidentitylabs.co.uk",
               Map.put(@indiid_data, :country, "GB")
             )
    end

    test "logo_url can be set directly" do
      assert %Organization{logo_url: "https://example.com/logo.png"} = Organization.new(
               "digital_identity",
               "digitalidentitylabs.co.uk",
               Map.put(@indiid_data, :logo_url, "https://example.com/logo.png")
             )
    end

    test "base_domain can be a URL or a plain domain name" do
      assert %Organization{base_domain: "digitalidentitylabs.co.uk"} = Organization.new(
               "digital_identity",
               "digitalidentitylabs.co.uk",
               %{}
             )
      assert %Organization{base_domain: "digitalidentitylabs.co.uk"} = Organization.new(
               "digital_identity",
               "https://digitalidentitylabs.co.uk",
               %{}
             )
    end

    test "the noid is normalized and often changed - it can be a name, and is converted" do
      assert %Organization{noid: "digital_identity"} = Organization.new(
               "Digital Identity Ltd",
               "https://digitalidentitylabs.co.uk",
               %{}
             )
    end

  end

  describe "name/2" do

    test "returns the English name, if no language is specified, and it is available" do
      assert "cern.ch" = Organization.name(@cern_org)
    end

    test "returns the specified language name if available" do
      assert "CERN" = Organization.name(@cern_org, "fr")
    end

    test "falls back to English/Default if specified is not available" do
      assert "cern.ch" = Organization.name(@cern_org, "br")
    end

  end

  describe "displayname/2" do
    test "returns the English name, if no language is specified, and it is available" do
      assert "CERN" = Organization.displayname(@cern_org)
    end

    test "returns the specified language name if available" do
      assert "Organisation européenne pour la recherche nucléaire" = Organization.displayname(@cern_org, "fr")
    end

    test "falls back to English/Default if specified is not available" do
      assert "CERN" = Organization.displayname(@cern_org, "br")
    end

  end

  describe "url/2" do
    test "returns the English URL, if no language is specified, and it is available" do
      assert "http://www.cern.ch/" = Organization.url(@cern_org)
    end

    test "returns the specified URL name if available" do
      assert "http://www.cern.ch/#french" = Organization.url(@cern_org, "fr")
    end

    test "falls back to English/Default URL if specified is not available" do
      assert "http://www.cern.ch/" = Organization.url(@cern_org, "br")
    end
  end

  describe "aggregated_text/1" do

    test "returns a mess of glued-together text fragments" do
      assert "cernch cern.ch CH https://edugain-sp-dev.web.cern.ch/saml2sp/saml2_backend.xml" <> _ =
               Organization.aggregated_text(@cern_org)
    end

    test "text includes domains" do
      assert String.contains?(Organization.aggregated_text(@cern_org), "cern.ch")
    end

    test "text includes names" do
      assert String.contains?(
               Organization.aggregated_text(@cern_org),
               "Organisation européenne pour la recherche nucléaire"
             )
    end

  end


  describe "langs/1" do

    test "returns codes for all languages in the Organization record (sorted)" do
      assert ["de", "en", "fr"] = Organization.langs(@cern_org)
    end

  end

  describe "tags/1" do

    test "returns a list of all tags in the record, as text, sorted" do
      assert ["ror"] = Organization.tags(@cern_org)
    end

  end

  describe "domains/1" do
    test "returns a list of all domains in the record, sorted" do
      assert ["cern.ch", "www.cern.ch"] = Organization.domains(@cern_org)
    end
  end

  describe "types/0" do
    test "returns a list of all types for organizations" do
      assert [
               :education,
               :healthcare,
               :company,
               :archive,
               :nonprofit,
               :government,
               :facility,
               :other,
               :unknown
             ] = Organization.types()
    end
  end

  describe "uri/1" do

    test "returns the struct's URI if present" do
      assert "https://cern.ch" = Organization.uri(%{@cern_org | uri: "https://cern.ch"})
    end

    test "returns ror URI if own URI is missing" do
      assert "https://ror.org/01ggx4157" = Organization.uri(%{@cern_org | ror: "https://ror.org/01ggx4157", uri: nil})
    end

    test "returns Smee URI if own URI and ror URI are missing" do
      assert "smee:org:noid:cernch" = Organization.uri(%{@cern_org | ror: nil, uri: nil})
    end

  end

  describe "uri/2" do

    test "returns a smee URI if :smee is the type" do
      assert "smee:org:noid:cernch" = Organization.uri(@cern_org, :smee)
    end

    test "returns a ROR URI if :ror is the type, and ROR URI is present" do
      assert "https://ror.org/01ggx4157" = Organization.uri(%{@cern_org | ror: "https://ror.org/01ggx4157"}, :ror)
    end

    test "returns nil if :ror is the type, and not present" do
      assert is_nil(Organization.uri(%{@cern_org | ror: nil}, :ror))
    end
    
  end

end
