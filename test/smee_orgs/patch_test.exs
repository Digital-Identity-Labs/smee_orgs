defmodule PatchTest do
  use ExUnit.Case

  alias SmeeOrgs.Patch

  @orgs "test/support/static/aggregate.xml"
        |> Smee.Source.new()
        |> Smee.Fetch.local!()
        |> SmeeOrgs.list()

  @patch_filename "test/support/static/patches.json"
  @patch_data File.read!(@patch_filename)
              |> Jason.decode!()

  @prepared_patch_data Patch.prepare_patches(@patch_data)

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

  describe "patch!/2" do

    test "can read a patch file when given a filename, and apply to a list of orgs" do
      assert @patched_orgs = Patch.patch!(@orgs, @patch_filename)
    end

    test "can use the data from a patch file directly (when given it as a list)" do
      assert @patched_orgs = Patch.patch!(@orgs, @patch_data)
    end

    test "can use prepared patch data when given a map, and apply to a list of orgs" do
      assert @patched_orgs = Patch.patch!(@orgs, @prepared_patch_data)
    end

  end

  describe "diff!/2" do

    test "returns a suitable patch fragment if given two organizations" do
      assert :ok = JsonComparator.compare(
               %{
                 "match" => "noid",
                 "patch" => [
                   %{path: "/federations/1", op: "remove"},
                   %{path: "/federations/0", op: "remove"},
                   %{path: "/registrars/0", op: "remove"},
                   %{value: "ukfederation.org.uk", path: "/domains/0", op: "replace"},
                   %{path: "/entity_uris/0", op: "remove"},
                   %{
                     value: "https://www.jisc.ac.uk/_next/static/media/jisc-logo.344be642.svg",
                     path: "/logo_url",
                     op: "replace"
                   },
                   %{value: nil, path: "/urls", op: "replace"},
                   %{value: nil, path: "/displaynames", op: "replace"},
                   %{value: nil, path: "/base_domain", op: "replace"},
                   %{value: nil, path: "/noid", op: "replace"},
                   %{value: nil, path: "/names", op: "replace"},
                   %{value: :other, path: "/type", op: "replace"}
                 ],
                 "priority" => 100
               },
               Patch.diff!(
                 List.first(@orgs),
                 %SmeeOrgs.Organization{
                   country: "GB",
                   domains: ["ukfederation.org.uk"],
                   logo_url: "https://www.jisc.ac.uk/_next/static/media/jisc-logo.344be642.svg",
                   type: :other
                 }
               )
             )
    end

  end

  describe "fetch!/1" do

    test "if passed a filename, reads and decodes that JSON file" do
      assert @patch_data = Patch.fetch!(@patch_filename)
    end

    test "if passed an HTTP url, reads and decodes the JSON" do
      assert @patch_data = Patch.fetch!(
               "https://raw.githubusercontent.com/Digital-Identity-Labs/smee_orgs/refs/heads/main/test/support/static/patches.json"
             )
    end

    test "if passed a file: url, reads and decodes the JSON" do
      assert @patch_data = Patch.fetch!("file:" <> @patch_filename)
    end

  end

  describe "valid?/1" do

    test "returns false if the data is not a list" do
      refute Patch.valid?("not patch data")
    end

    test "otherwise returns true (this is not a good validation test *at all*)" do
      assert Patch.valid?([])
    end

  end

  describe "validate!/1" do

    test "raises an exception if the data is not a list" do
      assert_raise(
        RuntimeError,
        fn ->
          Patch.validate!("not patch data")
        end
      )
    end

    test "otherwise returns the data" do
      assert [] = Patch.validate!([])
    end

  end

  describe "default_patch_location/0" do

    test "returns the path of the bundled patch data" do
      assert String.ends_with?(Patch.default_patch_location(), "smee_orgs/priv/patches/default.json")
    end

  end

  describe "prepare_patches/1" do

    test "processes the list of patch records into a map" do
      assert :ok = JsonComparator.compare(
               %{
                 "noid" => %{
                   "digital_identity" => [
                     %{
                       "match" => "noid",
                       "patch" => [
                         %{"op" => "replace", "path" => "/base_domain", "value" => "digitalidentity.ltd.uk"},
                         %{"op" => "replace", "path" => "/location", "value" => "Manchester"},
                         %{"op" => "replace", "path" => "/country", "value" => "GB"},
                         %{"op" => "replace", "path" => "/type", "value" => "company"},
                         %{
                           "op" => "add",
                           "path" => "/displaynames",
                           "value" => %{
                             "en" => "Digital Identity Ltd"
                           }
                         },
                         %{
                           "op" => "add",
                           "path" => "/names",
                           "value" => %{
                             "en" => "Digital Identity Ltd"
                           }
                         },
                         %{
                           "op" => "add",
                           "path" => "/urls",
                           "value" => %{
                             "en" => "https://digitalidentity.ltd.uk"
                           }
                         }
                       ],
                       "priority" => 100,
                       "when" => "digital_identity"
                     }
                   ],
                   "jisc" => [
                     %{
                       "match" => "noid",
                       "patch" => [
                         %{"op" => "replace", "path" => "/base_domain", "value" => "jisc.ac.uk"},
                         %{"op" => "replace", "path" => "/location", "value" => "Bristol"},
                         %{"op" => "replace", "path" => "/wikipedia", "value" => "https://en.wikipedia.org/wiki/Jisc"},
                         %{"op" => "replace", "path" => "/type", "value" => "other"},
                         %{
                           "op" => "add",
                           "path" => "/displaynames",
                           "value" => %{
                             "en" => "Jisc"
                           }
                         },
                         %{
                           "op" => "add",
                           "path" => "/names",
                           "value" => %{
                             "en" => "Jisc"
                           }
                         },
                         %{
                           "op" => "add",
                           "path" => "/urls",
                           "value" => %{
                             "en" => "https://jisc.ac.uk"
                           }
                         }
                       ],
                       "priority" => 100,
                       "when" => "jisc"
                     }
                   ],
                   "mimoto" => [
                     %{
                       "match" => "noid",
                       "patch" => [
                         %{"op" => "replace", "path" => "/location", "value" => "Manchester"},
                         %{
                           "op" => "replace",
                           "path" => "/logo_url",
                           "value" => "https://mimoto.co.uk/assets/images/mimoto.png"
                         },
                         %{"op" => "replace", "path" => "/type", "value" => "company"}
                       ],
                       "priority" => 100,
                       "when" => "mimoto"
                     }
                   ]
                 }
               },
               Patch.prepare_patches(@patch_data)
             )
    end

  end

end
