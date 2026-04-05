defmodule XPathsTest do
  use ExUnit.Case

  alias SmeeOrgs.XPaths

  @valid_xml File.read!("test/support/static/valid.xml")
  @valid_metadata "test/support/static/aggregate.xml"
                  |> Smee.Source.new()
                  |> Smee.Fetch.local!()
  @valid_entity Smee.Entity.derive(@valid_xml, @valid_metadata)
  @valid_xdoc @valid_entity.xdoc

  describe "extract_org/3" do

    test "when passed the parsed xdoc record for an entity, returns a map of org data" do

      assert %{
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
             } = XPaths.extract_org(@valid_entity.uri, @valid_metadata.uri, @valid_xdoc)

    end

  end


end
