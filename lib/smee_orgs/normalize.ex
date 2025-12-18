defmodule SmeeOrgs.Normalize do

  alias SmeeOrgs.NoidOverrides

  @punctuation [",", ".", "-", "'", "(", ")", "]", "[", ":", "+", "/", "\\", "’"]
  @company_name_prefixes ~r/\Athe /
  @company_name_suffixes ~r/\s(inc|ltd|llc|inc|oy|corp|plc|limited|co|sro|ale|sa|ag|bv|nv|ltee|bv|gmbh|sia|pte|pty|as|co ltd|identity_provider|idp|shibboleth|limited, the|the|.com|.net|.org)\Z/


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
        IO.warn "Invalid domain for organization: #{domain}!"
        nil
    end
  end

  ############


end
