defmodule RORTest do
  use ExUnit.Case

  alias SmeeOrgs.Organization
  alias SmeeOrgs.ROR
  alias ROR.Organization, as: ROROrganization

  @cern_org %Organization{
    type: "unknown",
    location: nil,
    names: %{
      "en" => "cern.ch"
    },
    ror: nil,
    base_domain: "cern.ch",
    urls: %{
      "en" => "http://www.cern.ch/"
    },
    displaynames: %{
      "en" => "CERN"
    },
    entity_uris: [
      "https://edugain-sp-dev.web.cern.ch/saml2sp/saml2_backend.xml",
      "https://edugain-sp-qa.web.cern.ch/saml2sp/saml2_backend.xml",
      "https://sp-proxy.cern.ch/saml2sp/saml2_backend.xml"
    ],
    federations: [
      "http://rr.aai.switch.ch/",
      "http://ukfederation.org.uk"
    ],
    registrars: [
      "http://rr.aai.switch.ch/"
    ],
    noid: "cernch",
    logo_url: nil,
    country: nil,
    domains: [
      "www.cern.ch"
    ],
    wikipedia: nil
  }

  @mimoto_org %Organization{
    type: "unknown",
    location: nil,
    names: %{
      "en" => "Mimoto Limited"
    },
    ror: nil,
    base_domain: "mimoto.co.uk",
    urls: %{
      "en" => "https://mimoto.co.uk/"
    },
    displaynames: %{
      "en" => "Mimoto Limited"
    },
    entity_uris: [
      "https://uom.doormou.se/shibboleth",
      "https://uom.doormouse.support/shibboleth",
      "https://uomdoormousedev.serotine.org/shibboleth"
    ],
    federations: [
      "http://ukfederation.org.uk"
    ],
    registrars: [
      "http://ukfederation.org.uk"
    ],
    noid: "mimoto",
    logo_url: nil,
    country: "GB",
    domains: [
      "mimoto.co.uk"
    ],
    wikipedia: nil
  }

  describe "get/1" do

    test "retrieves a ROR struct matching the organization, if one is available and can be matched" do

      assert %Elixir.ROR.Organization{
               established: 1954,
               id: "https://ror.org/01ggx4157",
               status: :active,
               types: [:facility, :funder]
             } = ROR.get(@cern_org)

    end

    test "returns nil if no ROR record is available, or if matching fails" do
      assert is_nil ROR.get(@mimoto_org)
    end

    #    test "returns the correct record for Lakeland College" do
    #
    #    end

    #    test "does not return Lakeland Collage for every record with LLC suffix..." do
    #      assert %Elixir.ROR.Organization{
    #               established: 1954,
    #               id: "https://ror.org/01ggx4157",
    #               status: :active,
    #               types: [:facility, :funder]
    #             } = ROR.get(@llc_org)
    #    end

  end

  describe "overlay/1" do

    test "overlays ROR data onto the passed Organization, if a suitable record can be found" do
      assert %Organization{
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
                 "en" => "cern.ch"
               },
               noid: "cernch",
               registrars: ["http://rr.aai.switch.ch/"],
               ror: "https://ror.org/01ggx4157",
               tags: [:ror],
               type: :facility,
               urls: %{
                 "en" => "http://www.cern.ch/"
               },
               wikipedia: "https://en.wikipedia.org/wiki/CERN"
             } = ROR.overlay(@cern_org)
    end

    test "leaves the original record untouched if no record can be found" do
      assert @mimoto_org = ROR.overlay(@mimoto_org)
    end

    test "adds a wikipedia URL to the organization if one is present in the ROR record" do
      assert %Organization{
               wikipedia: "https://en.wikipedia.org/wiki/CERN"
             } = ROR.overlay(@cern_org)
    end

    #    test "adds a new base_domain to the organization if one is present (and new)" do
    #
    #    end

    test "adds additional displaynames to the organization, if found" do
      assert %Organization{
               displaynames: %{
                 "de" => "Europäische Organisation für Kernforschung",
                 "en" => "CERN",
                 "fr" => "Organisation européenne pour la recherche nucléaire"
               }
             } = ROR.overlay(@cern_org)
    end

    test "replaces the country for the Organization, if found" do
      assert %Organization{
               country: "CH"
             } = ROR.overlay(@cern_org)
    end

    test "adds or replaces the location of the organization, if found" do
      assert %Organization{
               location: "Geneva"
             } = ROR.overlay(@cern_org)
    end

    test "updates the type of the Organization" do
      assert %Organization{
               type: :facility
             } = ROR.overlay(@cern_org)
    end

    #    test "will merge in any tags present in the ROR record" do
    #
    #    end

  end


end
