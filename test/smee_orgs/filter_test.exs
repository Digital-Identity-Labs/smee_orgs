defmodule FilterTest do
  use ExUnit.Case

  alias SmeeOrgs.Filter

  @orgs "test/support/static/aggregate.xml"
        |> Smee.Source.new()
        |> Smee.Fetch.local!()
        |> SmeeOrgs.list()
        |> SmeeOrgs.patch!()
        |> SmeeOrgs.enhance()

  describe "noid/3" do

    test "only allows organizations with the matching noid to pass" do
      assert [
               %SmeeOrgs.Organization{
                 noid: "mimoto"
               }
             ] = Filter.noid(@orgs, "mimoto")
    end

    test "a list of acceptable noids can be specified" do
      assert [
               %SmeeOrgs.Organization{
                 noid: "digital_identity"
               },
               %SmeeOrgs.Organization{
                 noid: "mimoto"
               }
             ] = Filter.noid(@orgs, ["mimoto", "digital_identity"])
    end

    test "setting false as the third parameter inverts the results" do
      assert [
               %SmeeOrgs.Organization{
                 noid: "jisc"
               },
               %SmeeOrgs.Organization{
                 noid: "digital_identity"
               },
               %SmeeOrgs.Organization{
                 noid: "cernch"
               }
             ] = Filter.noid(@orgs, "mimoto", false)
    end

  end

  describe "type/3" do

    test "only allows organizations with the matching type to pass" do
      assert [
               %SmeeOrgs.Organization{
                 noid: "digital_identity",
                 type: :company
               },
               %SmeeOrgs.Organization{
                 noid: "mimoto",
                 type: :company
               }
             ] = Filter.type(@orgs, :company)
    end

    test "setting false as the third parameter inverts the results" do
      assert [
               %SmeeOrgs.Organization{
                 noid: "jisc",
                # type: :nonprofit
                 type: :other
               },
               %SmeeOrgs.Organization{
                 noid: "cernch",
               #  type: :facility
                 type: :unknown
               }
             ] = Filter.type(@orgs, :company, false)
    end

  end


  describe "country/3" do

    test "only allows organizations with the matching country to pass" do
      assert [
               %SmeeOrgs.Organization{
                 country: "GB",
                 noid: "jisc"
               },
               %SmeeOrgs.Organization{
                 country: "GB",
                 noid: "digital_identity"
               },
               %SmeeOrgs.Organization{
                 country: "GB",
                 noid: "mimoto"
               }
             ] = Filter.country(@orgs, "GB")
    end

    test "works if the country code is in lowercase" do
      assert [
               %SmeeOrgs.Organization{
                 country: "GB",
                 noid: "jisc"
               },
               %SmeeOrgs.Organization{
                 country: "GB",
                 noid: "digital_identity"
               },
               %SmeeOrgs.Organization{
                 country: "GB",
                 noid: "mimoto"
               }
             ] = Filter.country(@orgs, "gb")
    end

    test "setting false as the third parameter inverts the results" do
      assert [
               %SmeeOrgs.Organization{
                 country: "CH",
                 noid: "cernch"
               }
             ] = Filter.country(@orgs, "GB", false)
    end
  end


  describe "domain/3" do
    test "only allows organizations with the matching domain to pass" do
      assert [
               %SmeeOrgs.Organization{
                 base_domain: "jisc.ac.uk",
                 noid: "jisc"
               }
             ] = Filter.domain(@orgs, "jisc.ac.uk")
    end

    test "setting false as the third parameter inverts the results" do
      assert [
               %SmeeOrgs.Organization{
                 base_domain: "digitalidentity.ltd.uk",
                 noid: "digital_identity"
               },
               %SmeeOrgs.Organization{
                 base_domain: "cern.ch",
                 noid: "cernch"
               },
               %SmeeOrgs.Organization{
                 base_domain: "mimoto.co.uk",
                 noid: "mimoto"
               }
             ] = Filter.domain(@orgs, "jisc.ac.uk", false)
    end
  end


#  describe "lang/3" do
#    test "only allows organizations with the matching language to pass" do
#      assert [
#               %SmeeOrgs.Organization{
#                 noid: "cernch"
#               },
#             ] = Filter.lang(@orgs, "fr")
#    end
#
#    test "setting false as the third parameter inverts the results" do
#      assert [
#               %SmeeOrgs.Organization{
#                 country: "GB",
#                 noid: "jisc"
#               },
#               %SmeeOrgs.Organization{
#                 country: "GB",
#                 noid: "digital_identity"
#               },
#               %SmeeOrgs.Organization{
#                 country: "GB",
#                 noid: "mimoto"
#               }
#             ] = Filter.lang(@orgs, "fr", false)
#    end
#  end


  describe "contains/3" do
    test "only allows organizations with fields that contain the specified text to pass" do
      assert [
               %SmeeOrgs.Organization{
                 noid: "jisc"
               }
             ] = Filter.contains(@orgs, "Jisc")
    end

    test "setting false as the third parameter inverts the results" do
      assert [
               %SmeeOrgs.Organization{
                 noid: "digital_identity"
               },
               %SmeeOrgs.Organization{
                 noid: "cernch"
               },
               %SmeeOrgs.Organization{
                 noid: "mimoto"
               }
             ] = Filter.contains(@orgs, "Jisc", false)
    end
  end


  describe "tag/3" do
#    test "only allows organizations with the matching tag to pass" do
#      assert  [
#                %SmeeOrgs.Organization{
#                  noid: "jisc",
#                  tags: [:ror],
#                },
#                %SmeeOrgs.Organization{
#                  noid: "cernch",
#                  tags: [:ror],
#                }
#              ] = Filter.tag(@orgs, "ror")
#    end

#    test "setting false as the third parameter inverts the results" do
#      assert [
#               %SmeeOrgs.Organization{
#                 noid: "digital_identity"
#               },
#               %SmeeOrgs.Organization{
#                 noid: "mimoto"
#               }
#             ] = Filter.tag(@orgs, "ror", false)
#    end
  end


end
