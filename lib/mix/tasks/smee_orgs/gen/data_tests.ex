defmodule Mix.Tasks.SmeeOrgs.Gen.DataTests do
  @moduledoc "Create a new set of compatibility tests, overwriting the existing set"
  @shortdoc "Create a new set of compatibility tests"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do

    IO.puts "Building basic compatibility test files..."

    SmeeFeds.federations()
    |> SmeeFeds.Filter.tag("noSlow", false)
    |> SmeeFeds.Filter.tag("noTest", false)
    |> Enum.each(
         fn federation ->

           fed_id = "#{federation.id}"
           module_name = "Data#{String.capitalize(fed_id)}CompatibilityTest"
           filename = "test/data/data_#{fed_id}_compatibility_test.exs"

           contents = """
             defmodule #{module_name} do
               use ExUnit.Case, async: false

               @moduletag :data

               describe "basic compatibility smoke test" do

                @tag timeout: 440_000
                 test "can download the metadata from #{fed_id} and parse a list of basic Organization records" do

                  orgs = SmeeFeds.federation(:#{fed_id})
                         |> SmeeFeds.Federation.aggregate()
                         |> Smee.fetch!()
                         |> SmeeOrgs.stream()
                         |> Enum.to_list()

                      assert Enum.all?(orgs, fn org -> is_struct(org, SmeeOrgs.Organization) end)

                 end

               end

             end

           """

           if File.exists?(filename) && String.contains?(File.read!(filename), "@protected") do
             IO.puts "Skipping #{filename} as it is marked as @protected"
           else
             IO.puts "Creating/overwriting #{filename}..."
             File.write!(filename, contents)
           end

           :ok
           
         end
       )

  end
end
