defmodule Mix.Tasks.SmeeOrgs.Data.Enhancements do
  @moduledoc "Show list of org enhancement data (ROR, Wikipedia, etc)"
  @shortdoc "Show list of org enhancement data (ROR, Wikipedia, etc)"

  use Mix.Task

  #alias Mix.Shell.IO
  alias SmeeOrgs

  @impl Mix.Task
  def run(_args) do

    {:ok, _} = Application.ensure_all_started(:req)

    source_url = System.get_env("MD_URL") || "http://metadata.ukfederation.org.uk/ukfederation-metadata.xml"

    IO.puts "Using #{source_url} for data. You can change this by setting MD_URL in your shell\nPlease wait...\n"

    rows = Smee.Source.new(source_url)
           |> Smee.fetch!()
           |> SmeeOrgs.list()
           |> SmeeOrgs.aggregate()
           |> SmeeOrgs.enhance()
           |> Enum.sort_by(& &1.noid)
           |> Enum.map(
                fn o ->
                  [o.noid, o.ror, o.wikipedia]
                end
              )

    title = "SmeeOrgs: Extracted simple Organization data"
    header = ["SmeeOrgs NOID", "ROR", "Wikipedia"]


    TableRex.quick_render!(rows, header, title)
    |> IO.puts

    IO.puts "#{Enum.count(rows)} organizations\n"
    
  end
end
