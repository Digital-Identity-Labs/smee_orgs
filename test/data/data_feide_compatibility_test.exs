  defmodule DataFeideCompatibilityTest do
    use ExUnit.Case, async: false

    @moduletag :data

    describe "basic compatibility smoke test" do

     @tag timeout: 440_000
      test "can download the metadata from feide and parse a list of basic Organization records" do

       orgs = SmeeFeds.federation(:feide)
              |> SmeeFeds.Federation.aggregate()
              |> Smee.fetch!()
              |> SmeeOrgs.stream()
              |> Enum.to_list()

           assert Enum.all?(orgs, fn org -> is_struct(org, SmeeOrgs.Organization) end)

      end

    end

  end

