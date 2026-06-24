defmodule Mix.Tasks.SmeeOrgs.Data.Logos do
  @moduledoc "Show list of org logos"
  @shortdoc "Show list of org logos"

  use Mix.Task

  #alias Mix.Shell.IO
  alias SmeeOrgs

  @dialyzer {:nowarn_function, run: 1}
  
  @impl Mix.Task
  def run(_args) do

    {:ok, _} = Application.ensure_all_started(:req)
    {:ok, _} = Application.ensure_all_started(:find_site_icon)

    source_url = System.get_env("MD_URL") || "http://metadata.ukfederation.org.uk/ukfederation-metadata.xml"

    IO.puts "Using #{source_url} for data. You can change this by setting MD_URL in your shell\nPlease wait...\n"

    rows = Smee.Source.new(source_url)
           |> Smee.fetch!()
           |> SmeeOrgs.list()
           |> SmeeOrgs.aggregate()
           |> SmeeOrgs.add_logos()
           |> Enum.sort_by(& &1.noid)
           |> Enum.map(
                fn o ->
                  [o.noid, o.logo_url]
                end
              )

    title = "SmeeOrgs: Extracted simple Organization data"
    header = ["SmeeOrgs NOID", "Logo URL"]


    TableRex.quick_render!(rows, header, title)
    |> IO.puts

    IO.puts "#{Enum.count(rows)} organizations\n"

    :ok
  end
end
