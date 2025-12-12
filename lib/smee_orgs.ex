defmodule SmeeOrgs do

  alias SmeeOrgs.ROR

  def stream(input) do

  end

  def list(input) do

  end

  ## Don't change, but remove duplicates (two modes, different methods - like time, or first)
  def unique(enum, opts \\ []) do

  end

  ## Merge different version together, even creating multi-language versions
  def merge(enum, opts \\ []) do

  end

  ## Use extra data to enhance records - ROR, country data, etc. Patch/overlays can go here
  def enhance(enum, opts \\ []) do
    Enum.map(enum, fn org -> ROR.overlay(org) end)
  end

  ## Use extra data to enhance records - ROR, country data, etc. Patch/overlays can go here
  def patch(enum, opts \\ []) do

  end

end
