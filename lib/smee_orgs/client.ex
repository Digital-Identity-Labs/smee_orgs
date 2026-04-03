defmodule SmeeOrgs.Client do
  @moduledoc false

  @default_http_options [
    http_errors: :raise,
    cache: true,
    max_redirects: 3,
    max_retries: 3,
    headers: %{
      "accept" => "application/json",
      "accept-charset" => "utf-8"
    }
  ]

  @spec get!(url :: binary(), opts :: keyword()) :: map()
  def get!(url, opts \\ []) do
    Req.get!(http(opts), url: url).body
  end

  @doc false
  @spec http(opts :: keyword()) :: map()
  def http(opts \\ []) do
    Keyword.merge(@default_http_options, Keyword.get(opts, :http, []))
    |> Keyword.merge(user_agent: http_agent_name())
    |> Keyword.merge(cache_dir: Smee.SysCfg.cache_directory())
    |> Keyword.merge(retry_delay: &retry_jitter/1)
    |> Req.new()
  end

  @doc false
  @spec http_agent_name() :: binary()
  def http_agent_name do
    "SmeeOrgs #{Application.spec(:smee_orgs, :vsn)}"
  end
  
  ######################################################################################

  @spec retry_jitter(n :: integer()) :: integer()
  defp retry_jitter(n) do
    trunc(Integer.pow(2, n) * 1000 * (1 - 0.1 * :rand.uniform()))
  end

end
