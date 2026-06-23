defmodule SmeeOrgsTest do
  use ExUnit.Case
  doctest SmeeOrgs

  ## Mostly smoketests because lower-level modules do the work and already have tests, I hope

  @valid_metadata "test/support/static/aggregate.xml"
                  |> Smee.Source.new()
                  |> Smee.Fetch.local!()

  @entity Smee.Metadata.entities(@valid_metadata)
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

  @orgs @valid_metadata
        |> SmeeOrgs.list()

  @patch_filename "test/support/static/patches.json"
  @patch_data File.read!(@patch_filename)
              |> Jason.decode!()

  @prepared_patch_data SmeeOrgs.Patch.prepare_patches(@patch_data)

  @patched_orgs [
    %SmeeOrgs.Organization{
      base_domain: "jisc.ac.uk",
      country: "GB",
      displaynames: %{
        "en" => "Jisc"
      },
      domains: ["www.ukfederation.org.uk"],
      entity_uris: ["https://test.ukfederation.org.uk/entity"],
      federations: ["http://example.com/federation", "http://ukfederation.org.uk"],
      location: "Bristol",
      logo_url: nil,
      names: %{
        "en" => "Jisc"
      },
      noid: "jisc",
      registrars: ["http://ukfederation.org.uk"],
      ror: nil,
      tags: [],
      type: :other,
      urls: %{
        "en" => "https://jisc.ac.uk"
      },
      wikipedia: "https://en.wikipedia.org/wiki/Jisc"
    },
    %SmeeOrgs.Organization{
      base_domain: "digitalidentity.ltd.uk",
      country: "GB",
      displaynames: %{
        "en" => "Digital Identity Ltd"
      },
      domains: ["indiid.net"],
      entity_uris: ["https://indiid.net/idp/shibboleth"],
      federations: ["http://example.com/federation", "http://ukfederation.org.uk"],
      location: "Manchester",
      logo_url: nil,
      names: %{
        "en" => "Digital Identity Ltd"
      },
      noid: "digital_identity",
      registrars: ["http://ukfederation.org.uk"],
      ror: nil,
      tags: [],
      type: :company,
      urls: %{
        "en" => "https://digitalidentity.ltd.uk"
      },
      wikipedia: nil
    },
    %SmeeOrgs.Organization{
      base_domain: "cern.ch",
      country: "CH",
      displaynames: %{
        "en" => "CERN"
      },
      domains: ["www.cern.ch"],
      entity_uris: ["https://cern.ch/login"],
      federations: ["http://example.com/federation", "http://rr.aai.switch.ch/"],
      location: nil,
      logo_url: nil,
      names: %{
        "en" => "cern.ch"
      },
      noid: "cernch",
      registrars: ["http://rr.aai.switch.ch/"],
      ror: nil,
      tags: [],
      type: :unknown,
      urls: %{
        "en" => "http://www.cern.ch/"
      },
      wikipedia: nil
    },
    %SmeeOrgs.Organization{
      base_domain: "mimoto.co.uk",
      country: "GB",
      displaynames: %{
        "en" => "Mimoto Limited"
      },
      domains: ["mimoto.co.uk"],
      entity_uris: ["https://uom.doormou.se/shibboleth"],
      federations: ["http://example.com/federation", "http://ukfederation.org.uk"],
      location: "Manchester",
      logo_url: "https://mimoto.co.uk/assets/images/mimoto.png",
      names: %{
        "en" => "Mimoto Limited"
      },
      noid: "mimoto",
      registrars: ["http://ukfederation.org.uk"],
      ror: nil,
      tags: [],
      type: :company,
      urls: %{
        "en" => "https://mimoto.co.uk"
      },
      wikipedia: nil
    }
  ]

  describe "new/3" do

    test "will return a minimal, useless Organization record with only the first two params" do

      assert %SmeeOrgs.Organization{
               noid: "test_org",
               base_domain: "test.org"
             } = SmeeOrgs.new("test_org", "test.org")

    end

  end

  describe "extract/1" do

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
             } = SmeeOrgs.extract(@entity)
    end


  end

  describe "stream/2" do

    test "converts a stream of entity records into a stream of organization records" do
      assert %Stream{} = Smee.Metadata.stream_entities(@valid_metadata)
                         |> SmeeOrgs.stream()

      assert @org = Smee.Metadata.stream_entities(@valid_metadata)
                    |> SmeeOrgs.stream(@entity)
                    |> Stream.take(1)
                    |> Enum.to_list()
                    |> List.first()
    end

    test "converts a single entity record into a stream of organization records" do
      assert is_function SmeeOrgs.stream(@entity)

      assert @org = SmeeOrgs.stream(@entity)
                    |> Stream.take(1)
                    |> Enum.to_list()
                    |> List.first()
    end

    test "converts a list of entity records into a stream of organization records" do
      assert %Stream{} = Smee.Metadata.entities(@valid_metadata)
                         |> SmeeOrgs.stream()

      assert @org = Smee.Metadata.entities(@valid_metadata)
                    |> SmeeOrgs.stream()
                    |> Stream.take(1)
                    |> Enum.to_list()
                    |> List.first()
    end

    test "converts a Smee Metadata struct into a stream of organization records" do
      assert %Stream{} = SmeeOrgs.stream(@valid_metadata)

      assert @org = SmeeOrgs.stream(@valid_metadata)
                    |> Stream.take(1)
                    |> Enum.to_list()
                    |> List.first()
    end


  end

  describe "list/2" do

    test "converts a stream of entity records into a list of organization records" do
      assert is_list Smee.Metadata.stream_entities(@valid_metadata)
                     |> SmeeOrgs.list()

      assert @org = Smee.Metadata.stream_entities(@valid_metadata)
                    |> SmeeOrgs.list(@entity)
                    |> List.first()
    end

    test "converts a single entity record into a list of organization records" do
      assert is_list SmeeOrgs.list(@entity)

      assert @org = SmeeOrgs.list(@entity)
                    |> List.first()
    end

    test "converts a list of entity records into a list of organization records" do
      assert is_list Smee.Metadata.entities(@valid_metadata)
                     |> SmeeOrgs.list()

      assert @org = Smee.Metadata.entities(@valid_metadata)
                    |> SmeeOrgs.list()
                    |> List.first()
    end

    test "converts a Smee Metadata struct into a list of organization records" do
      assert is_list SmeeOrgs.list(@valid_metadata)

      assert @org = SmeeOrgs.list(@valid_metadata)
                    |> List.first()
    end



  end

  describe "unique/2" do
    test "drops all repeated records by NOID" do
      assert [
               %SmeeOrgs.Organization{
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
               },
               %SmeeOrgs.Organization{
                 base_domain: "indiid.net",
                 country: "ZZ",
                 displaynames: %{
                   "en" => "Indiid"
                 },
                 domains: ["indiid.net"],
                 entity_uris: ["https://indiid.net/idp/shibboleth"],
                 federations: ["http://example.com/federation", "http://ukfederation.org.uk"],
                 location: nil,
                 logo_url: nil,
                 names: %{
                   "en" => "Digital Identity Ltd"
                 },
                 noid: "digital_identity",
                 registrars: ["http://ukfederation.org.uk"],
                 ror: nil,
                 tags: [],
                 type: :unknown,
                 urls: %{
                   "en" => "https://indiid.net/"
                 },
                 wikipedia: nil
               },
               %SmeeOrgs.Organization{
                 base_domain: "cern.ch",
                 country: "CH",
                 displaynames: %{
                   "en" => "CERN"
                 },
                 domains: ["www.cern.ch"],
                 entity_uris: ["https://cern.ch/login"],
                 federations: ["http://example.com/federation", "http://rr.aai.switch.ch/"],
                 location: nil,
                 logo_url: nil,
                 names: %{
                   "en" => "cern.ch"
                 },
                 noid: "cernch",
                 registrars: ["http://rr.aai.switch.ch/"],
                 ror: nil,
                 tags: [],
                 type: :unknown,
                 urls: %{
                   "en" => "http://www.cern.ch/"
                 },
                 wikipedia: nil
               },
               %SmeeOrgs.Organization{
                 base_domain: "mimoto.co.uk",
                 country: "GB",
                 displaynames: %{
                   "en" => "Mimoto Limited"
                 },
                 domains: ["mimoto.co.uk"],
                 entity_uris: ["https://uom.doormou.se/shibboleth"],
                 federations: ["http://example.com/federation", "http://ukfederation.org.uk"],
                 location: nil,
                 logo_url: nil,
                 names: %{
                   "en" => "Mimoto Limited"
                 },
                 noid: "mimoto",
                 registrars: ["http://ukfederation.org.uk"],
                 ror: nil,
                 tags: [],
                 type: :unknown,
                 urls: %{
                   "en" => "https://mimoto.co.uk"
                 },
                 wikipedia: nil
               }
             ] = SmeeOrgs.uniq(@orgs ++ @orgs)
    end
  end

  describe "uniq/2" do
    test "drops all repeated records by NOID" do
      assert [
               %SmeeOrgs.Organization{
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
               },
               %SmeeOrgs.Organization{
                 base_domain: "indiid.net",
                 country: "ZZ",
                 displaynames: %{
                   "en" => "Indiid"
                 },
                 domains: ["indiid.net"],
                 entity_uris: ["https://indiid.net/idp/shibboleth"],
                 federations: ["http://example.com/federation", "http://ukfederation.org.uk"],
                 location: nil,
                 logo_url: nil,
                 names: %{
                   "en" => "Digital Identity Ltd"
                 },
                 noid: "digital_identity",
                 registrars: ["http://ukfederation.org.uk"],
                 ror: nil,
                 tags: [],
                 type: :unknown,
                 urls: %{
                   "en" => "https://indiid.net/"
                 },
                 wikipedia: nil
               },
               %SmeeOrgs.Organization{
                 base_domain: "cern.ch",
                 country: "CH",
                 displaynames: %{
                   "en" => "CERN"
                 },
                 domains: ["www.cern.ch"],
                 entity_uris: ["https://cern.ch/login"],
                 federations: ["http://example.com/federation", "http://rr.aai.switch.ch/"],
                 location: nil,
                 logo_url: nil,
                 names: %{
                   "en" => "cern.ch"
                 },
                 noid: "cernch",
                 registrars: ["http://rr.aai.switch.ch/"],
                 ror: nil,
                 tags: [],
                 type: :unknown,
                 urls: %{
                   "en" => "http://www.cern.ch/"
                 },
                 wikipedia: nil
               },
               %SmeeOrgs.Organization{
                 base_domain: "mimoto.co.uk",
                 country: "GB",
                 displaynames: %{
                   "en" => "Mimoto Limited"
                 },
                 domains: ["mimoto.co.uk"],
                 entity_uris: ["https://uom.doormou.se/shibboleth"],
                 federations: ["http://example.com/federation", "http://ukfederation.org.uk"],
                 location: nil,
                 logo_url: nil,
                 names: %{
                   "en" => "Mimoto Limited"
                 },
                 noid: "mimoto",
                 registrars: ["http://ukfederation.org.uk"],
                 ror: nil,
                 tags: [],
                 type: :unknown,
                 urls: %{
                   "en" => "https://mimoto.co.uk"
                 },
                 wikipedia: nil
               }
             ] = SmeeOrgs.uniq(@orgs ++ @orgs)
    end
  end

  describe "merge/2" do

    test "merges all records, even if that makes no sense" do
      assert %SmeeOrgs.Organization{
               base_domain: "ukfederation.org.uk",
               country: "GB",
               displaynames: %{
                 "en" => "UK federation Test SP"
               },
               domains: ["indiid.net", "mimoto.co.uk", "www.cern.ch", "www.ukfederation.org.uk"],
               entity_uris: [
                 "https://cern.ch/login",
                 "https://indiid.net/idp/shibboleth",
                 "https://test.ukfederation.org.uk/entity",
                 "https://uom.doormou.se/shibboleth"
               ],
               federations: ["http://example.com/federation", "http://rr.aai.switch.ch/", "http://ukfederation.org.uk"],
               location: nil,
               logo_url: nil,
               names: %{
                 "en" => "Jisc Services Limited"
               },
               noid: "jisc",
               registrars: ["http://rr.aai.switch.ch/", "http://ukfederation.org.uk"],
               ror: nil,
               type: :unknown,
               urls: %{
                 "en" => "http://www.ukfederation.org.uk/"
               },
               wikipedia: nil
             } = SmeeOrgs.merge(@orgs)
    end


  end

  describe "aggregate/2" do
    test "merges records that have the same noid" do
      assert [
               %SmeeOrgs.Organization{
                 base_domain: "cern.ch",
                 country: "CH",
                 displaynames: %{
                   "en" => "CERN"
                 },
                 domains: ["www.cern.ch"],
                 entity_uris: ["https://cern.ch/login"],
                 federations: ["http://example.com/federation", "http://rr.aai.switch.ch/"],
                 location: nil,
                 logo_url: nil,
                 names: %{
                   "en" => "cern.ch"
                 },
                 noid: "cernch",
                 registrars: ["http://rr.aai.switch.ch/"],
                 ror: nil,
                 type: :unknown,
                 urls: %{
                   "en" => "http://www.cern.ch/"
                 },
                 wikipedia: nil
               },
               %SmeeOrgs.Organization{
                 base_domain: "indiid.net",
                 country: "ZZ",
                 displaynames: %{
                   "en" => "Indiid"
                 },
                 domains: ["indiid.net"],
                 entity_uris: ["https://indiid.net/idp/shibboleth"],
                 federations: ["http://example.com/federation", "http://ukfederation.org.uk"],
                 location: nil,
                 logo_url: nil,
                 names: %{
                   "en" => "Digital Identity Ltd"
                 },
                 noid: "digital_identity",
                 registrars: ["http://ukfederation.org.uk"],
                 ror: nil,
                 type: :unknown,
                 urls: %{
                   "en" => "https://indiid.net/"
                 },
                 wikipedia: nil
               },
               %SmeeOrgs.Organization{
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
                 type: :unknown,
                 urls: %{
                   "en" => "http://www.ukfederation.org.uk/"
                 },
                 wikipedia: nil
               },
               %SmeeOrgs.Organization{
                 base_domain: "mimoto.co.uk",
                 country: "GB",
                 displaynames: %{
                   "en" => "Mimoto Limited"
                 },
                 domains: ["mimoto.co.uk"],
                 entity_uris: ["https://uom.doormou.se/shibboleth"],
                 federations: ["http://example.com/federation", "http://ukfederation.org.uk"],
                 location: nil,
                 logo_url: nil,
                 names: %{
                   "en" => "Mimoto Limited"
                 },
                 noid: "mimoto",
                 registrars: ["http://ukfederation.org.uk"],
                 ror: nil,
                 type: :unknown,
                 urls: %{
                   "en" => "https://mimoto.co.uk"
                 },
                 wikipedia: nil
               }
             ] = SmeeOrgs.aggregate(
               @orgs ++ @orgs
             ) ## This is a bad test and I should feel bad (it's indistinguishable from uniq/3)
    end
  end

  describe "enhance/2" do

    test "runs Tidy enhancements on all records" do
      assert [
               %SmeeOrgs.Organization{
                 noid: "jisc",
                 type: :company
               },
               %SmeeOrgs.Organization{
                 noid: "digital_identity",
                 type: :unknown
                 # ??
               },
               %SmeeOrgs.Organization{
                 noid: "cernch",
                 #type: :facility
                 type: :unknown
               },
               %SmeeOrgs.Organization{
                 noid: "mimoto",
                 type: :company
               }
             ] = SmeeOrgs.enhance(@orgs)
    end

    test "runs ROR enhancements on all records" do
      assert [
               %SmeeOrgs.Organization{
                 noid: "jisc",
                 ror: nil
               },
               %SmeeOrgs.Organization{
                 noid: "digital_identity",
                 ror: nil,
               },
               %SmeeOrgs.Organization{
                 noid: "cernch",
            #     ror: "https://ror.org/01ggx4157",
                 ror: nil,
               },
               %SmeeOrgs.Organization{
                 noid: "mimoto",
                 ror: nil,
               }
             ] = SmeeOrgs.enhance(@orgs)
    end

  end

  describe "add_logos/2" do

    test "Adds logo URLs to records if they can be found" do
      assert [
               %SmeeOrgs.Organization{
                 logo_url: "https://ukfederation.org.uk/favicon.ico",
                 noid: "jisc"
               },
               %SmeeOrgs.Organization{
                 logo_url: "https://indiid.net/favicon.ico",
                 noid: "digital_identity"
               },
               %SmeeOrgs.Organization{
                 logo_url: "https://home.cern/wp-content/uploads/2026/05/cropped-favicon-cern-180x180.png",
                 noid: "cernch"
               },
               %SmeeOrgs.Organization{
                 logo_url: "https://mimoto.co.uk/apple-touch-icon.png",
                 noid: "mimoto"
               }
             ] = SmeeOrgs.add_logos(@orgs)
    end
  end

  describe "patch!/1" do

    test "can patch orgs with the default data" do
      assert [
               %SmeeOrgs.Organization{
                 base_domain: "jisc.ac.uk",
                 country: "GB",
                 location: "Bristol",
                 names: %{"en" => "Jisc"},
                 noid: "jisc",
                 wikipedia: "https://en.wikipedia.org/wiki/Jisc"
               },
               %SmeeOrgs.Organization{
                 noid: "digital_identity",
                 type: :company,
               },
               %SmeeOrgs.Organization{
                 base_domain: "cern.ch",
                 country: "CH",
                 displaynames: %{"en" => "CERN"},
                 noid: "cernch",
               },
               %SmeeOrgs.Organization{
                 logo_url: "https://mimoto.co.uk/assets/images/mimoto.png",
                 noid: "mimoto",
                 type: :company,
               }
             ] = SmeeOrgs.patch!(@orgs)
    end
    
  end

  describe "patch!/3" do

    test "can read a patch file when given a filename, and apply to a list of orgs" do
      assert @patched_orgs = SmeeOrgs.patch!(@orgs, @patch_filename)
    end

    test "can use the data from a patch file directly (when given it as a list)" do
      assert @patched_orgs = SmeeOrgs.patch!(@orgs, @patch_data)
    end

    test "can use prepared patch data when given a map, and apply to a list of orgs" do
      assert @patched_orgs = SmeeOrgs.patch!(@orgs, @prepared_patch_data)
    end

  end

  describe "dump/3" do

    @tag :tmp_dir
    test "writes all records to disk as JSON", %{tmp_dir: tmp_dir} do
      assert :ok = SmeeOrgs.dump(@orgs, "#{tmp_dir}/dump.json")
    end

    @tag :tmp_dir
    test "the file is a list of JSON records", %{tmp_dir: tmp_dir} do
      filename = "#{tmp_dir}/dump.json"
      :ok = SmeeOrgs.dump(@orgs, filename)
      assert [
               %{
                 "base_domain" => "ukfederation.org.uk",
                 "country" => "GB",
                 "displaynames" => %{
                   "en" => "UK federation Test SP"
                 },
                 "domains" => ["www.ukfederation.org.uk"],
                 "entity_uris" => ["https://test.ukfederation.org.uk/entity"],
                 "federations" => ["http://example.com/federation", "http://ukfederation.org.uk"],
                 "location" => nil,
                 "logo_url" => nil,
                 "names" => %{
                   "en" => "Jisc Services Limited"
                 },
                 "noid" => "jisc",
                 "registrars" => ["http://ukfederation.org.uk"],
                 "ror" => nil,
                 "tags" => [],
                 "type" => "unknown",
                 "urls" => %{
                   "en" => "http://www.ukfederation.org.uk/"
                 },
                 "wikipedia" => nil
               },
               %{
                 "base_domain" => "indiid.net",
                 "country" => "ZZ",
                 "displaynames" => %{
                   "en" => "Indiid"
                 },
                 "domains" => ["indiid.net"],
                 "entity_uris" => ["https://indiid.net/idp/shibboleth"],
                 "federations" => ["http://example.com/federation", "http://ukfederation.org.uk"],
                 "location" => nil,
                 "logo_url" => nil,
                 "names" => %{
                   "en" => "Digital Identity Ltd"
                 },
                 "noid" => "digital_identity",
                 "registrars" => ["http://ukfederation.org.uk"],
                 "ror" => nil,
                 "tags" => [],
                 "type" => "unknown",
                 "urls" => %{
                   "en" => "https://indiid.net/"
                 },
                 "wikipedia" => nil
               },
               %{
                 "base_domain" => "cern.ch",
                 "country" => "CH",
                 "displaynames" => %{
                   "en" => "CERN"
                 },
                 "domains" => ["www.cern.ch"],
                 "entity_uris" => ["https://cern.ch/login"],
                 "federations" => ["http://example.com/federation", "http://rr.aai.switch.ch/"],
                 "location" => nil,
                 "logo_url" => nil,
                 "names" => %{
                   "en" => "cern.ch"
                 },
                 "noid" => "cernch",
                 "registrars" => ["http://rr.aai.switch.ch/"],
                 "ror" => nil,
                 "tags" => [],
                 "type" => "unknown",
                 "urls" => %{
                   "en" => "http://www.cern.ch/"
                 },
                 "wikipedia" => nil
               },
               %{
                 "base_domain" => "mimoto.co.uk",
                 "country" => "GB",
                 "displaynames" => %{
                   "en" => "Mimoto Limited"
                 },
                 "domains" => ["mimoto.co.uk"],
                 "entity_uris" => ["https://uom.doormou.se/shibboleth"],
                 "federations" => ["http://example.com/federation", "http://ukfederation.org.uk"],
                 "location" => nil,
                 "logo_url" => nil,
                 "names" => %{
                   "en" => "Mimoto Limited"
                 },
                 "noid" => "mimoto",
                 "registrars" => ["http://ukfederation.org.uk"],
                 "ror" => nil,
                 "tags" => [],
                 "type" => "unknown",
                 "urls" => %{
                   "en" => "https://mimoto.co.uk"
                 },
                 "wikipedia" => nil
               }
             ] = File.read!(filename)
                 |> Jason.decode!()
    end

  end

end
