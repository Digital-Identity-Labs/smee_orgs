defmodule SmeeOrgs.Normalize do

  @moduledoc false

  alias SmeeOrgs.NoidOverrides

  @punctuation [",", ".", "-", "'", "(", ")", "]", "[", ":", "+", "/", "\\", "’"]
  @company_name_prefixes ~r/\Athe /
  @company_name_suffixes ~r/\s(inc|ltd|llc|inc|oy|corp|plc|limited|co|sro|ale|sa|ag|bv|nv|ltee|bv|gmbh|sia|pte|pty|as|co ltd|identity_provider|idp|shibboleth|limited, the|the|.com|.net|.org)\Z/
  @org_types [:education, :healthcare, :company, :archive, :nonprofit, :government, :facility, :other, :unknown]


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

  def lang_map(map) do
    map
    |> Enum.map(fn {k, v} -> {lang_key(k), lang_value(v)} end)
    |> Map.new()
  end

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

  def lang_value(value) do
    String.trim(value)
  end

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

  def type(type) when is_binary(type) do
    String.to_existing_atom(type)
    |> type()
  end

  def type(type) when is_atom(type) and type in @org_types do
    type
  end

  def type(type) do
    raise "Organization type '#{type}' is unknown!}"
  end

  def types do
    @org_types
  end

  ############


end
