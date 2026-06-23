defmodule ExtractTest do
  use ExUnit.Case

  @valid_metadata "test/support/static/aggregate.xml"
                  |> Smee.Source.new()
                  |> Smee.Fetch.local!()

  @entity Smee.Metadata.entities(@valid_metadata)
          |> List.first()

  @no_org_metadata "test/support/static/no_org.xml"
                   |> Smee.Source.new()
                   |> Smee.Fetch.local!()

  @no_org_entity Smee.Metadata.entities(@no_org_metadata)
          |> List.first()


  @org %SmeeOrgs.Organization{
    base_domain: "ukfederation.org.uk",
    country: "GB",
    displaynames: %{
      "en" => "UK federation Test SP"
    },
    domains: ["www.ukfederation.org.uk"],
    entity_uris: ["https://test.ukfederation.org.uk/entity"],
    federations: ["http://example.com/federation", "http://ukfederation.org.uk"],
    location: nil,
    logo_url: nil,
    names: %{
      "en" => "Jisc Services Limited"
    },
    noid: "jisc",
    registrars: ["http://ukfederation.org.uk"],
    ror: nil,
    tags: [],
    type: :unknown,
    urls: %{
      "en" => "http://www.ukfederation.org.uk/"
    },
    wikipedia: nil
  }

  alias SmeeOrgs.Extract

  describe "select_name/2" do

    test "selects a name (value) from a lang map of names, defaulting to English" do
      assert "hello" = Extract.select_name(%{"en" => "hello", "fr" => "bonjour"})
    end

    test "selects a name (value) from a lang map of names, using the specified language" do
      assert "bonjour" = Extract.select_name(%{"en" => "hello", "fr" => "bonjour"}, "fr")
    end

  end

  describe "select_domain/2" do

    test "selects a domain/URL (value) from a lang map of URLs" do
      assert "http://uk.example.com" = Extract.select_name(
               %{"en" => "http://uk.example.com", "fr" => "http://fr.example.com"}
             )
    end

  end

  describe "one/1" do

    test "converts one Entity struct into one Organization struct using new/3" do

      assert %SmeeOrgs.Organization{
               base_domain: "ukfederation.org.uk",
               country: "GB",
               displaynames: %{
                 "en" => "UK federation Test SP"
               },
               domains: ["www.ukfederation.org.uk"],
               entity_uris: ["https://test.ukfederation.org.uk/entity"],
               federations: ["http://example.com/federation", "http://ukfederation.org.uk"],
               location: nil,
               logo_url: nil,
               names: %{
                 "en" => "Jisc Services Limited"
               },
               noid: "jisc",
               registrars: ["http://ukfederation.org.uk"],
               ror: nil,
               tags: [],
               type: :unknown,
               urls: %{
                 "en" => "http://www.ukfederation.org.uk/"
               },
               wikipedia: nil
             } = Extract.one(@entity)
    end

    test "if no organization data is present in the Entity, return the unknown record" do

      assert %SmeeOrgs.Organization{
               base_domain: nil,
               country: "ZZ",
               displaynames: %{"en" => "Unknown"},
               domains: [],
               entity_uris: ["https://indiid.net/idp/shibboleth"],
               federations: ["http://ukfederation.org.uk", "https://indiid.net/idp/shibboleth"],
               location: nil,
               logo_url: nil,
               names: %{"en" => "Unknown"},
               noid: "unknown",
               registrars: ["http://ukfederation.org.uk"],
               ror: nil,
               tags: [],
               type: :unknown,
               urls: %{},
               wikipedia: nil
             } = Extract.one(@no_org_entity)
    end
    
  end

  describe "stream/2" do

    test "converts a stream of entity records into a stream of organization records" do
      assert %Stream{} = Smee.Metadata.stream_entities(@valid_metadata)
                         |> Extract.stream()

      assert @org = Smee.Metadata.stream_entities(@valid_metadata)
                    |> Extract.stream(@entity)
                    |> Stream.take(1)
                    |> Enum.to_list()
                    |> List.first()
    end

    test "converts a single entity record into a stream of organization records" do
      assert is_function Extract.stream(@entity)

      assert @org = Extract.stream(@entity)
                    |> Stream.take(1)
                    |> Enum.to_list()
                    |> List.first()
    end

    test "converts a list of entity records into a stream of organization records" do
      assert %Stream{} = Smee.Metadata.entities(@valid_metadata)
                         |> Extract.stream()

      assert @org = Smee.Metadata.entities(@valid_metadata)
                    |> Extract.stream()
                    |> Stream.take(1)
                    |> Enum.to_list()
                    |> List.first()
    end

    test "converts a Smee Metadata struct into a stream of organization records" do
      assert %Stream{} = Extract.stream(@valid_metadata)

      assert @org = Extract.stream(@valid_metadata)
                    |> Stream.take(1)
                    |> Enum.to_list()
                    |> List.first()
    end

  end

end
