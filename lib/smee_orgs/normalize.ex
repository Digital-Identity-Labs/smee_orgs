defmodule SmeeOrgs.Normalize do

  @moduledoc false

  require Logger
  
  alias SmeeOrgs.NoidOverrides

  @punctuation [",", ".", "-", "'", "(", ")", "]", "[", ":", "+", "/", "\\", "’"]
  @company_name_prefixes ~r/\Athe /
  @company_name_suffixes ~r/\s(inc|ltd|llc|inc|oy|corp|plc|incorporated|corporation|limited|co|sro|ale|sa|ag|bv|nv|ltee|bv|gmbh|sia|pte|pty|as|co ltd|identity_provider|idp|sp|test|shibboleth|vle|moodle|limited, the|the|.com|.net|.org)\Z/
  @org_types [:education, :healthcare, :company, :archive, :nonprofit, :government, :facility, :other, :unknown]

  @spec noid(name :: binary()) :: binary()
  def noid(name) do
    "#{name}"
    |> String.downcase()
    |> String.trim()
    |> String.replace(@company_name_prefixes, "")
    |> String.replace(@company_name_suffixes, "")
    |> String.replace(@punctuation, "")
    |> String.trim()
    |> String.replace(" ", "_")
    |> String.replace("__", "_")
    |> NoidOverrides.builtin()
  end

  @spec lang_map(map :: map() | nil) :: map()
  def lang_map(nil) do
    %{}
  end

  def lang_map(map) do
    map
    |> Enum.map(fn {k, v} -> {lang_key(k), lang_value(v)} end)
    |> Map.new()
  end

  @spec lang_key(nowt :: nil | binary() | atom()) :: binary()
  def lang_key(nowt) when nowt == "" or is_nil(nowt) do
    "en"
  end

  def lang_key(key) when is_atom(key) do
    to_string(key)
    |> lang_key()
  end

  def lang_key(key) do
    key
    |> String.split("-")
    |> List.first()
    |> String.downcase()
  end

  @spec lang_value(value :: binary()) :: binary()
  def lang_value(value) do
    to_string(value)
    |> String.trim()
  end

  @spec url(url :: nil | binary()) :: binary()
  def url(nil) do
    nil
  end

  def url(not_even_invalid) when not_even_invalid in ["unspecified", ":", "localhost", "GOSC", ""] do
    nil
  end

  def url("http" <> _ = url) do
    url = String.trim(url)
    cond do
      String.contains?(url, ".localhost") -> nil
      String.contains?(url, "localhost:") -> nil
      String.contains?(url, ".internal") -> nil
      true -> url
    end
  end

  ## Should actually catch unacceptable schemas some other way TODO
  def url("mailto:" <> _) do
    nil
  end

  def url("ldap:" <> _) do
    nil
  end

  def url(invalid_url) do
    url = String.trim(invalid_url)
    cond do
      String.starts_with?(url, "http") -> url(url)
      String.contains?(url, ".") -> url("https://#{url}")
      true -> nil
    end
  end

  @spec base_domain(url :: nil | binary()) :: binary()
  def base_domain(nowt) when nowt in [nil, "", "unspecified"] do
    nil
  end

  def base_domain("http" <> _ = url) do
    bits = URI.new!(url)
    base_domain(bits.host)
  end

  def base_domain(domain) do
    case Domainatrex.parse(domain) do
      {:ok, bits} -> Enum.join([bits[:domain], bits[:tld]], ".")
      {:error, msg} ->
        IO.warn "Invalid domain for organization: #{domain}: #{msg}!"
        nil
    end
  end

  @spec type(type :: atom() | binary()) :: atom()
  def type(type) when is_atom(type) and type in @org_types do
    type
  end

  def type(type) when is_binary(type) do
    try do
      String.to_existing_atom(type)
      |> type()
    rescue
      _ -> Logger.warning "Unknown Organization type '#{type}'"
           :unknown
    end
  end

  def type(type) do
    Logger.warning "Unknown Organization type '#{type}'"
    :unknown
  end

  @spec types() :: list(atom())
  def types do
    @org_types
  end

  ############

end
