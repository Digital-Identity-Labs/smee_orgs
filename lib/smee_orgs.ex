defmodule SmeeOrgs do

  alias SmeeOrgs.Patch
  alias SmeeOrgs.Organization
  alias SmeeOrgs.Extract
  alias SmeeOrgs.Process

  @spec new(name_id :: binary(), domain :: binary(), data :: map() | keyword()) :: Organization.t()
  def new(name_id, domain, data) do
    Organization.new(name_id, domain, data)
  end

  @spec extract(entity :: Smee.Entity.t()) :: Organization.t()
  def extract(entity) do
    Extract.one(entity)
  end

  @spec stream(input :: %Stream{}, opts :: keyword()) :: %Stream{} ## Fix this
  def stream(input, opts \\ []) do
    Extract.stream(input, opts)
  end

  @spec list(input :: %Stream{}, opts :: keyword()) :: list() ## Fix this too
  def list(input, opts \\ []) do
    stream(input, opts)
    |> Enum.to_list()
  end

  ## Don't change, but remove duplicates (two modes, different methods - like time, or first)
  @spec unique(enum :: Enumerable.t(), opts :: keyword()) :: Enumerable.t()
  def unique(enum, opts \\ []) do
    Process.uniq(enum, opts)
  end

  ## Same as above
  @spec uniq(enum :: Enumerable.t(), opts :: keyword()) :: Enumerable.t()
  def uniq(enum, opts \\ []) do
    Process.uniq(enum, opts)
  end

  ## Merge org records together whatever they are
  @spec merge(enum :: Enumerable.t(), opts :: keyword()) :: Enumerable.t()
  def merge(enum, opts \\ []) do
    Process.merge(enum, opts)
  end

  ## Merge org records with same ID together
  @spec aggregate(enum :: Enumerable.t(), opts :: keyword()) :: Enumerable.t()
  def aggregate(enum, opts \\ []) do
    Process.aggregate(enum, opts)
  end

  ## Use extra data to enhance records - ROR, country data, etc. Patch/overlays can go here
  @spec enhance(enum :: Enumerable.t(), opts :: keyword()) :: Enumerable.t()
  def enhance(enum, opts \\ []) do
    Process.enhance(enum, opts)
  end
  
  @spec add_logos(enum :: Enumerable.t(), opts :: keyword()) :: Enumerable.t()
  def add_logos(enum, opts \\ [force: false]) do
    Process.add_logos(enum, opts)
  end

  
  @spec patch!(enum :: Enumerable.t()) :: Enumerable.t()
  def patch!(enum) do
    Patch.patch!(enum, Patch.default_patch_location())
  end

 
  @spec patch!(enum :: Enumerable.t(), source :: binary(), opts :: keyword()) :: Enumerable.t()
  def patch!(enum, source, _opts \\ []) do
    Patch.patch!(enum, source)
  end
  
  @spec dump(enum :: Enumerable.t(), filename :: binary(), opts :: keyword()) :: Enumerable.t()
  def dump(enum, filename \\ "orgs_dump.json", opts \\ []) do
    Process.dump(enum, filename, opts)
  end

end
