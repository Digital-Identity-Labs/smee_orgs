defmodule SmeeOrgs do

  alias SmeeOrgs.Patch
  alias SmeeOrgs.Organization
  alias SmeeOrgs.Extract
  alias SmeeOrgs.ROR
  alias SmeeOrgs.Process

  def new(name_id, domain, data) do
    Organization.new(name_id, domain, data)
  end

  def extract(entity) do
    Extract.one(entity)
  end

  def stream(input, opts \\ []) do
    Extract.stream(input, opts)
  end

  def list(input, opts \\ []) do
    stream(input, opts)
    |> Enum.to_list()
  end

  ## Don't change, but remove duplicates (two modes, different methods - like time, or first)
  def unique(enum, opts \\ []) do
    Process.uniq(enum, opts)
  end

  ## Same as above
  def uniq(enum, opts \\ []) do
    Process.uniq(enum, opts)
  end

  ## Merge org records together whatever they are
  def merge(enum, opts \\ []) do
    Process.merge(enum, opts)
  end

  ## Merge org records with same ID together
  def aggregate(enum, opts \\ []) do
    Process.aggregate(enum, opts)
  end

  ## Use extra data to enhance records - ROR, country data, etc. Patch/overlays can go here
  def enhance(enum, opts \\ []) do
    Process.enhance(enum, opts)
  end

  ## Use extra data to enhance records - ROR, country data, etc. Patch/overlays can go here
  def patch!(enum) do
    Patch.patch!(enum, Patch.default_patch_location())
  end

  ## Use extra data to enhance records - ROR, country data, etc. Patch/overlays can go here
  def patch!(enum, source, opts \\ []) do
    Patch.patch!(enum, source, opts)
  end

  ## Use extra data to enhance records - ROR, country data, etc. Patch/overlays can go here
  def dump(enum, filename \\ "orgs_dump.json", opts \\ []) do
    Process.dump(enum, filename, opts)
  end

end
