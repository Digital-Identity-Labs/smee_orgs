#!/usr/bin/env elixir
Mix.install([{:smee, ">= 0.6.0"}, {:smee_orgs, ">= 0.1.0", path: ".."}])

Smee.Source.new("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")
|> Smee.fetch!()
|> Smee.Metadata.stream_entities()
|> Smee.Filter.sp()
|> SmeeOrgs.stream()
|> SmeeOrgs.aggregate()
|> SmeeOrgs.add_logos()
|> Enum.each(fn o -> IO.puts o.logo_uri end)

