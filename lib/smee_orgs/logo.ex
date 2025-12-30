defmodule SmeeOrgs.Logo do

  @moduledoc false

  require Logger

  alias SmeeOrgs.Normalize
  alias SmeeOrgs.Organization
  alias SmeeOrgs.Utils

  def add_site_logo_url(org, opts) do
    url = case FindSiteIcon.find_icon("https://#{org.base_domain}") do
      {:ok, url} -> Logger.debug("Found icon for #{org.noid} at #{url}")
                    if opts[:force] do
                      %{org | logo_url: url}
                    else
                      %{org | logo_url: Utils.set_if_empty(org.logo_url, url)}
                    end
      {:error, reason} -> Logger.debug("No icon found for #{org.noid} (#{reason})")
                          org
    end

  end



end
