defmodule SmeeOrgs.Logo do

  @moduledoc false

  require Logger

  alias SmeeOrgs.Utils
  alias SmeeOrgs.Organization
  alias SmeeOrgs.Client

  @default_fsi_options [pool_max_idle_time: 30_000]

  @spec add_site_logo_url(org :: Organization.t(), opts :: keyword()) :: Organization.t()
  def add_site_logo_url(org, opts \\ []) do
    case FindSiteIcon.find_icon("https://#{org.base_domain}", fsi_options(opts)) do
      {:ok, url} -> Logger.debug("Found icon for #{org.noid} at #{url}")
                    if opts[:force] do
                      %{org | logo_url: url}
                    else
                      %{org | logo_url: Utils.set_if_empty(org.logo_url, url)}
                    end
      {:error, reason} -> Logger.debug("No icon found for #{org.noid}: #{reason}")
                          org
    end

  end

  @spec fsi_options(opts :: keyword()) :: keyword()
  defp fsi_options(opts) do
    Keyword.merge(
      @default_fsi_options,
      [
        timeout: opts[:timeout] || 40_000,
        default_icon_url: opts[:default_icon_url],
        http_options: [
          user_agent: Client.http_agent_name(),
          cache_dir: Smee.SysCfg.cache_directory(),
          max_redirects: 10,
          max_retries: 1
        ]
      ]
    )
  end

end
