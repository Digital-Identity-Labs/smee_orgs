defmodule SmeeOrgs.Filter do

  alias SmeeOrgs.Normalize
  alias SmeeOrgs.Organization

  @spec noid(enum :: Enumerable.t(), noids :: binary() | list(binary()), bool :: boolean()) :: Enumerable.t()
  def noid(enum, noids, bool \\ true) do
    enum
    |> Enum.filter(fn o -> (Enum.member?(List.wrap(noids), o.noid)) == bool end)
  end

  @spec type(enum :: Enumerable.t(), type :: binary() | atom(), bool :: boolean()) :: Enumerable.t()
  def type(enum, type, bool \\ true) do
    enum
    |> Enum.filter(fn o -> (Normalize.type(type) == o.type) == bool end)
  end

  @spec country(enum :: Enumerable.t(), country :: binary() | atom(), bool :: boolean()) :: Enumerable.t()
  def country(enum, country, bool \\ true) do
    enum
    |> Enum.filter(fn o -> (String.upcase("#{country}") == o.country) == bool end)
  end

  @spec domain(enum :: Enumerable.t(), domain :: binary(), bool :: boolean()) :: Enumerable.t()
  def domain(enum, domain, bool \\ true) do
    enum
    |> Enum.filter(fn o -> Enum.member?(Organization.domains(o), domain) == bool end)
  end

  @spec lang(enum :: Enumerable.t(), lang :: binary(), bool :: boolean()) :: Enumerable.t()
  def lang(enum, lang, bool \\ true) do
    enum
    |> Enum.filter(fn o -> String.downcase("#{lang}") in Organization.langs(o) == bool end)
  end

  @spec contains(enum :: Enumerable.t(), text :: binary(), bool :: boolean()) :: Enumerable.t()
  def contains(enum, text, bool \\ true) do
    enum
    |> Enum.filter(fn o -> (String.contains?(Organization.aggregated_text(o), String.downcase("#{text}"))) == bool end)
  end

  @doc """
  Filters a stream of organizations to include or exclude those that have the specified tag.

  It's best to provide the tag as a string.

  The filter is positive by default but can be inverted by specifying `false`
  """
  @spec tag(enum :: Enumerable.t(), tag :: binary() | atom(), bool :: boolean()) :: Enumerable.t()
  def tag(enum, tag, bool \\ true)

  def tag(enum, tag, bool) when is_atom(tag) do
    tag(enum, Atom.to_string(tag), bool)
  end

  def tag(enum, tag, bool) do
    enum
    |> Enum.filter(fn l -> (tag in Organization.tags(l)) == bool end)
  end

  #######################################################


end