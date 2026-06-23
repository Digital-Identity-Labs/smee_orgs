defmodule ProcessTest do
  use ExUnit.Case

  alias SmeeOrgs.Process

  @orgs "test/support/static/aggregate.xml"
        |> Smee.Source.new()
        |> Smee.Fetch.local!()
        |> SmeeOrgs.list()
        |> List.delete_at(2) ## Temp quick fix for ROR failing to work with metadata name, remove after next ROR update

  describe "enhance/2" do

    test "runs Tidy enhancements on all records" do
      assert [
               %SmeeOrgs.Organization{
                 noid: "jisc",
                 type: :company
               },
               %SmeeOrgs.Organization{
                 noid: "digital_identity",
                 type: :unknown # ??
               },
#               %SmeeOrgs.Organization{
#                 noid: "cernch",
#                 type: :facility
#               },
               %SmeeOrgs.Organization{
                 noid: "mimoto",
                 type: :company
               }
             ] = Process.enhance(@orgs)
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
#               %SmeeOrgs.Organization{
#                 noid: "cernch",
#                 ror: "https://ror.org/01ggx4157",
#               },
               %SmeeOrgs.Organization{
                 noid: "mimoto",
                 ror: nil,
               }
             ] = Process.enhance(@orgs)
    end

  end

  describe "uniq/2" do

    test "drops all repeated records by NOID" do
      assert [
               %SmeeOrgs.Organization{
                 base_domain: "ukfederation.org.uk",
                 country: "GB",
                 displaynames: %{"en" => "UK federation Test SP"},
                 domains: ["www.ukfederation.org.uk"],
                 entity_uris: ["https://test.ukfederation.org.uk/entity"],
                 federations: ["http://example.com/federation", "http://ukfederation.org.uk"],
                 location: nil,
                 logo_url: nil,
                 names: %{"en" => "Jisc Services Limited"},
                 noid: "jisc",
                 registrars: ["http://ukfederation.org.uk"],
                 ror: nil,
                 tags: [],
                 type: :unknown,
                 urls: %{"en" => "http://www.ukfederation.org.uk/"},
                 wikipedia: nil
               },
               %SmeeOrgs.Organization{
                 base_domain: "indiid.net",
                 country: "ZZ",
                 displaynames: %{"en" => "Indiid"},
                 domains: ["indiid.net"],
                 entity_uris: ["https://indiid.net/idp/shibboleth"],
                 federations: ["http://example.com/federation", "http://ukfederation.org.uk"],
                 location: nil,
                 logo_url: nil,
                 names: %{"en" => "Digital Identity Ltd"},
                 noid: "digital_identity",
                 registrars: ["http://ukfederation.org.uk"],
                 ror: nil,
                 tags: [],
                 type: :unknown,
                 urls: %{"en" => "https://indiid.net/"},
                 wikipedia: nil
               },
#               %SmeeOrgs.Organization{
#                 base_domain: "cern.ch",
#                 country: "CH",
#                 displaynames: %{"en" => "CERN"},
#                 domains: ["www.cern.ch"],
#                 entity_uris: ["https://cern.ch/login"],
#                 federations: ["http://example.com/federation", "http://rr.aai.switch.ch/"],
#                 location: nil,
#                 logo_url: nil,
#                 names: %{"en" => "cern.ch"},
#                 noid: "cernch",
#                 registrars: ["http://rr.aai.switch.ch/"],
#                 ror: nil,
#                 tags: [],
#                 type: :unknown,
#                 urls: %{"en" => "http://www.cern.ch/"},
#                 wikipedia: nil
#               },
               %SmeeOrgs.Organization{
                 base_domain: "mimoto.co.uk",
                 country: "GB",
                 displaynames: %{"en" => "Mimoto Limited"},
                 domains: ["mimoto.co.uk"],
                 entity_uris: ["https://uom.doormou.se/shibboleth"],
                 federations: ["http://example.com/federation", "http://ukfederation.org.uk"],
                 location: nil,
                 logo_url: nil,
                 names: %{"en" => "Mimoto Limited"},
                 noid: "mimoto",
                 registrars: ["http://ukfederation.org.uk"],
                 ror: nil,
                 tags: [],
                 type: :unknown,
                 urls: %{"en" => "https://mimoto.co.uk"},
                 wikipedia: nil
               }
             ] = Process.uniq(@orgs ++ @orgs)
    end
  end

  describe "merge/2" do

    test "merges all records, even if that makes no sense" do
      assert %SmeeOrgs.Organization{
               base_domain: "ukfederation.org.uk",
               country: "GB",
               displaynames: %{"en" => "UK federation Test SP"},
               #domains: ["indiid.net", "mimoto.co.uk", "www.cern.ch", "www.ukfederation.org.uk"],
               domains: ["indiid.net", "mimoto.co.uk", "www.ukfederation.org.uk"],
              # entity_uris: ["https://cern.ch/login", "https://indiid.net/idp/shibboleth", "https://test.ukfederation.org.uk/entity", "https://uom.doormou.se/shibboleth"],
               entity_uris: ["https://indiid.net/idp/shibboleth", "https://test.ukfederation.org.uk/entity", "https://uom.doormou.se/shibboleth"],
               #federations: ["http://example.com/federation", "http://rr.aai.switch.ch/", "http://ukfederation.org.uk"],
               federations: ["http://example.com/federation", "http://ukfederation.org.uk"],
               location: nil,
               logo_url: nil,
               names: %{"en" => "Jisc Services Limited"},
               noid: "jisc",
               #registrars: ["http://rr.aai.switch.ch/", "http://ukfederation.org.uk"],
               registrars: ["http://ukfederation.org.uk"],
               ror: nil,
               tags: [:merge],
               type: :unknown,
               urls: %{"en" => "http://www.ukfederation.org.uk/"},
               wikipedia: nil
             } = Process.merge(@orgs)
    end

    ## I should probably have a test here that shows merged records that *do* make sense, but I'm tired.
    
  end

  describe "aggregate/2" do

    test "merges records that have the same noid" do
      assert [
#               %SmeeOrgs.Organization{
#                 base_domain: "cern.ch",
#                 country: "CH",
#                 displaynames: %{"en" => "CERN"},
#                 domains: ["www.cern.ch"],
#                 entity_uris: ["https://cern.ch/login"],
#                 federations: ["http://example.com/federation", "http://rr.aai.switch.ch/"],
#                 location: nil,
#                 logo_url: nil,
#                 names: %{"en" => "cern.ch"},
#                 noid: "cernch",
#                 registrars: ["http://rr.aai.switch.ch/"],
#                 ror: nil,
#                 tags: [:aggregate],
#                 type: :unknown,
#                 urls: %{"en" => "http://www.cern.ch/"},
#                 wikipedia: nil
#               },
               %SmeeOrgs.Organization{
                 base_domain: "indiid.net",
                 country: "ZZ",
                 displaynames: %{"en" => "Indiid"},
                 domains: ["indiid.net"],
                 entity_uris: ["https://indiid.net/idp/shibboleth"],
                 federations: ["http://example.com/federation", "http://ukfederation.org.uk"],
                 location: nil,
                 logo_url: nil,
                 names: %{"en" => "Digital Identity Ltd"},
                 noid: "digital_identity",
                 registrars: ["http://ukfederation.org.uk"],
                 ror: nil,
                 tags: [:aggregate],
                 type: :unknown,
                 urls: %{"en" => "https://indiid.net/"},
                 wikipedia: nil
               },
               %SmeeOrgs.Organization{
                 base_domain: "ukfederation.org.uk",
                 country: "GB",
                 displaynames: %{"en" => "UK federation Test SP"},
                 domains: ["www.ukfederation.org.uk"],
                 entity_uris: ["https://test.ukfederation.org.uk/entity"],
                 federations: ["http://example.com/federation", "http://ukfederation.org.uk"],
                 location: nil,
                 logo_url: nil,
                 names: %{"en" => "Jisc Services Limited"},
                 noid: "jisc",
                 registrars: ["http://ukfederation.org.uk"],
                 ror: nil,
                 tags: [:aggregate],
                 type: :unknown,
                 urls: %{"en" => "http://www.ukfederation.org.uk/"},
                 wikipedia: nil
               },
               %SmeeOrgs.Organization{
                 base_domain: "mimoto.co.uk",
                 country: "GB",
                 displaynames: %{"en" => "Mimoto Limited"},
                 domains: ["mimoto.co.uk"],
                 entity_uris: ["https://uom.doormou.se/shibboleth"],
                 federations: ["http://example.com/federation", "http://ukfederation.org.uk"],
                 location: nil,
                 logo_url: nil,
                 names: %{"en" => "Mimoto Limited"},
                 noid: "mimoto",
                 registrars: ["http://ukfederation.org.uk"],
                 ror: nil,
                 tags: [:aggregate],
                 type: :unknown,
                 urls: %{"en" => "https://mimoto.co.uk"},
                 wikipedia: nil
               }
             ] = Process.aggregate(@orgs ++ @orgs) ## This is a bad test and I should feel bad (it's indistinguishable from uniq/3)
    end
  end


  describe "dump/3" do

    @tag :tmp_dir
    test "writes all records to disk as JSON", %{tmp_dir: tmp_dir} do
      assert :ok = Process.dump(@orgs, "#{tmp_dir}/dump.json")
    end

    @tag :tmp_dir
    test "the file is a list of JSON records", %{tmp_dir: tmp_dir} do
      filename = "#{tmp_dir}/dump.json"
      :ok = Process.dump(@orgs, filename)
      assert [
               %{
                 "base_domain" => "ukfederation.org.uk",
                 "country" => "GB",
                 "displaynames" => %{"en" => "UK federation Test SP"},
                 "domains" => ["www.ukfederation.org.uk"],
                 "entity_uris" => ["https://test.ukfederation.org.uk/entity"],
                 "federations" => ["http://example.com/federation", "http://ukfederation.org.uk"],
                 "location" => nil,
                 "logo_url" => nil,
                 "names" => %{"en" => "Jisc Services Limited"},
                 "noid" => "jisc",
                 "registrars" => ["http://ukfederation.org.uk"],
                 "ror" => nil,
                 "tags" => [],
                 "type" => "unknown",
                 "urls" => %{"en" => "http://www.ukfederation.org.uk/"},
                 "wikipedia" => nil
               },
               %{
                 "base_domain" => "indiid.net",
                 "country" => "ZZ",
                 "displaynames" => %{"en" => "Indiid"},
                 "domains" => ["indiid.net"],
                 "entity_uris" => ["https://indiid.net/idp/shibboleth"],
                 "federations" => ["http://example.com/federation", "http://ukfederation.org.uk"],
                 "location" => nil,
                 "logo_url" => nil,
                 "names" => %{"en" => "Digital Identity Ltd"},
                 "noid" => "digital_identity",
                 "registrars" => ["http://ukfederation.org.uk"],
                 "ror" => nil,
                 "tags" => [],
                 "type" => "unknown",
                 "urls" => %{"en" => "https://indiid.net/"},
                 "wikipedia" => nil
               },
#               %{
#                 "base_domain" => "cern.ch",
#                 "country" => "CH",
#                 "displaynames" => %{"en" => "CERN"},
#                 "domains" => ["www.cern.ch"],
#                 "entity_uris" => ["https://cern.ch/login"],
#                 "federations" => ["http://example.com/federation", "http://rr.aai.switch.ch/"],
#                 "location" => nil,
#                 "logo_url" => nil,
#                 "names" => %{"en" => "cern.ch"},
#                 "noid" => "cernch",
#                 "registrars" => ["http://rr.aai.switch.ch/"],
#                 "ror" => nil,
#                 "tags" => [],
#                 "type" => "unknown",
#                 "urls" => %{"en" => "http://www.cern.ch/"},
#                 "wikipedia" => nil
#               },
               %{
                 "base_domain" => "mimoto.co.uk",
                 "country" => "GB",
                 "displaynames" => %{"en" => "Mimoto Limited"},
                 "domains" => ["mimoto.co.uk"],
                 "entity_uris" => ["https://uom.doormou.se/shibboleth"],
                 "federations" => ["http://example.com/federation", "http://ukfederation.org.uk"],
                 "location" => nil,
                 "logo_url" => nil,
                 "names" => %{"en" => "Mimoto Limited"},
                 "noid" => "mimoto",
                 "registrars" => ["http://ukfederation.org.uk"],
                 "ror" => nil,
                 "tags" => [],
                 "type" => "unknown",
                 "urls" => %{"en" => "https://mimoto.co.uk"},
                 "wikipedia" => nil
               }
             ] = File.read!(filename) |> Jason.decode!()
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
#               %SmeeOrgs.Organization{
#                 logo_url: nil,
#                 noid: "cernch"
#               },
               %SmeeOrgs.Organization{
                 logo_url: "https://mimoto.co.uk/apple-touch-icon.png",
                 noid: "mimoto"
               }
             ] = Process.add_logos(@orgs)
    end
  end

  describe "add_uris/2" do

    test "Adds URIs to records, defaulting to Smee style" do
      assert [
               %SmeeOrgs.Organization{
                 uri: "smee:org:noid:jisc",
                 noid: "jisc"
               },
               %SmeeOrgs.Organization{
                 uri: "smee:org:noid:digital_identity",
                 noid: "digital_identity"
               },
#               %SmeeOrgs.Organization{
#                 uri: nil,
#                 noid: "cernch"
#               },
               %SmeeOrgs.Organization{
                 uri: "smee:org:noid:mimoto",
                 noid: "mimoto"
               }
             ] = Process.add_uris(@orgs)
    end
  end
  
end
