defmodule Mix.Tasks.SmeeOrgs.Data.Aggregated do
  @moduledoc "List of aggregated org data"
  @shortdoc "List of aggregated org data"

  use Mix.Task

  #alias Mix.Shell.IO
  alias SmeeOrgs

  @dialyzer {:nowarn_function, run: 1}
  
  @impl Mix.Task
  def run(_args) do

    {:ok, _} = Application.ensure_all_started(:req)

    source_url = System.get_env("MD_URL") || "http://metadata.ukfederation.org.uk/ukfederation-metadata.xml"

    IO.puts "Using #{source_url} for data. You can change this by setting MD_URL in your shell\nPlease wait...\n"

    rows = Smee.Source.new(source_url)
           |> Smee.fetch!()
           |> SmeeOrgs.list()
           |> SmeeOrgs.aggregate()
           |> Enum.sort_by(& &1.noid)
           |> Enum.map(
                fn o ->
                  [o.noid, String.trim(SmeeOrgs.Organization.displayname(o))]
                end
              )

    title = "SmeeOrgs: Extracted simple Organization data"
    header = ["SmeeOrgs NOID", "Displayname"]


    TableRex.quick_render!(rows, header, title)
    |> IO.puts

    IO.puts "#{Enum.count(rows)} organizations\n"


    :ok
    
  end
end
