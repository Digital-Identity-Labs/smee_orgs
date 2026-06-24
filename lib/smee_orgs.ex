defmodule SmeeOrgs do

  @moduledoc """
  `SmeeOrgs` is an extension to [Smee](https://github.com/Digital-Identity-Labs/smee) dedicated to extracting and processing
  the Organization information inside SAML entity metadata. Rather niche but possibly useful.

  Organisation data is not a load-bearing aspect of SAML metadata - it's not used during authentication, and nothing breaks
  if it's incorrect. It can also be difficult for federations to manage and maintain. SmeeOrgs offers features that hopefully
  fix and improve this organisation data and make it more useful.
    
  ## Features

  * Extract organization data from Smee entity structs and metadata, as lists or streams.
  * Assign simple identifers to organizations
  * Easily filter lists of organisations by type, tags, and other criteria.
  * Merge, deduplicate and aggregate duplicated records
  * Enhance organisation records with [ROR](https://ror.org) data
  * Patch organisation data to hopefully fix and improve it
  * Find and add logos automatically
  * Export Organization data as JSON

  The top level `SmeeOrgs` module has functions for extracting and processing lists of organisations from Metadata.
  Two other modules may be of use:

  * `SmeeOrgs.Filter` - simple filtering functions for selecting Organisations by various criteria
  * `SmeeOrgs.Organization` - a struct for organisation data and functions for easily accessing the data

  ## Problems and Possible Solutions 

  * **Identifiers**: There is no single strong identifer in the metadata fragment for Organisation data - names and URLs are localized 
  * **Duplication**: Organization data is included with each Entity so it's naturally duplicated if an Organization has more 
    than one IdP or SP. If you want to assemble more structured and normalized data, maybe mapping services to 
    service-providing organisations, then you need to deduplicate it.
  * **Inconsistency**: Organization data is normally added to federations piecemeal - the same organization may be described 
    with different details. Federations may describe the same organisation with different details, and organisations may
    not provide consistent descriptions of themselves.
  * **Stale data**: Organizations change over time, they rename or merge, change their websites and update branding. There's
    no need to contact federations to update organization details (nothing will break) so the data drifts away from reality.
  * **Legacy workarounds**: Before MDUI data could be included in metadata it was common to use Organisation data to describe 
    the service, not the organization. Many of these remain in metadata today.

  Organisation information in SAML metadata isn't very important - nothing breaks if it contains errors, but because of this
  errors can gradually acrue over time until making any use of it all may be difficult.

  SmeeOrgs was created to (hopefully) build usable lists of organizations and their services. It attempts to make the raw 
  information in SAML metadata more useful by doing the following:

  * Assign identifiers to each record: an ID derived from a name, and a base domain.
  * Attempt to fix identifiers so that records that have very different names get the same ID
  * Deduplicate and merge records so that records that *appear* to be the same organization are combined 
  * Apply patches to data to fix and improve records
  * Lookup organizations using the ROR API to add additional information
  * Find suitable logos/icons

  At present a lot of the approaches listed above are a little too much like gaffer-tape. They appear to work remarkably well but 
  errors will remain and you may find it necessary to add your own fixes. SmeeOrgs' patch functions can be used to do this but
  it should be pretty easy to process the data in other ways too. The patch data included in SmeeOrgs is a demo and a starting-point: 
  you should probably put together your own patch data for production use, or at least review the default patch data.

  Please see the contributing section below if you have suggestions or fixes you wish to share.
  """
  
  alias SmeeOrgs.Patch
  alias SmeeOrgs.Organization
  alias SmeeOrgs.Extract
  alias SmeeOrgs.Process

  @doc false 
  @spec new(name_id :: binary(), domain :: binary(), data :: map() | keyword()) :: Organization.t()
  def new(name_id, domain, data \\ %{}) do
    Organization.new(name_id, domain, data)
  end

  @doc """
  Extracts a single Organization struct from a Smee Entity struct
  
  The returned organization struct will contain the bare minimum of information and a "noid" ID derived from
    the English or default name of the organization. Entities without organization data produce an organization
    with the ID "unknown" 
  """
  @spec extract(entity :: Smee.Entity.t()) :: Organization.t()
  def extract(entity) do
    Extract.one(entity)
  end

  @doc """
  Returns a stream of Organization structs when provided with Smee Metadata or a list or Stream of Entity structs.
  
  The returned organization structs will contain the bare minimum of information and a "noid" ID derived from
    the English or default name of the organization. Entities without organization data produce an organization
    with the ID "unknown"
  """
  @spec stream(input :: %Stream{}, opts :: keyword()) :: %Stream{} ## Fix this
  def stream(input, opts \\ []) do
    Extract.stream(input, opts)
  end

  @doc """
  Returns a list of Organization structs when provided with Smee Metadata or a list or Stream of Entity structs.

  Apart from returning a list this behaves exactly like `stream/2` and only exists for clarity and convenience.  
  """
  @spec list(input :: %Stream{}, opts :: keyword()) :: list() ## Fix this too
  def list(input, opts \\ []) do
    stream(input, opts)
    |> Enum.to_list()
  end

  @doc """
  Removes duplicate Organizations from a list or stream or Organizations based on their NOID. 
  
  The first record with an ID is kept, others are discarded. This is very crude and may not be what you
    want.
  """
  ## Don't change, but remove duplicates (two modes, different methods - like time, or first)
  @spec unique(enum :: Enumerable.t(), opts :: keyword()) :: Enumerable.t()
  def unique(enum, opts \\ []) do
    Process.uniq(enum, opts)
  end

  @doc """
  Removes duplicate Organizations from a list or stream or Organizations based on their NOID. 
  
  This is exactly the same as `unique/2` and exists because I'm constantly forgetting whether a language or library
    uses "uniq" or "unique".
  """
  ## Same as above
  @spec uniq(enum :: Enumerable.t(), opts :: keyword()) :: Enumerable.t()
  def uniq(enum, opts \\ []) do
    Process.uniq(enum, opts)
  end

  @doc """
  Merges the entire list of Organizations into one Organization struct
    
  This is mostly for use when you know exactly what's in the list of Organizations. If you want to 
    merge together records that appear to by the same organization use `aggregate/2` instead.
  """
  ## Merge org records together whatever they are
  @spec merge(enum :: Enumerable.t(), opts :: keyword()) :: Enumerable.t()
  def merge(enum, opts \\ []) do
    Process.merge(enum, opts)
  end

  @doc """
  Merges together all Organization structs that share exactly the same ID.
  
  This is probably the best way to quickly deduplicate a raw list of Organizations extracted from federated
    metadata.
  """
  ## Merge org records with same ID together
  @spec aggregate(enum :: Enumerable.t(), opts :: keyword()) :: Enumerable.t()
  def aggregate(enum, opts \\ []) do
    Process.aggregate(enum, opts)
  end

  @doc """
  Tries to improve a list of Organizations by deriving data and using external APIs.
  
  It will lookup ROR details for each Organization. Many publishing organizations will lack ROR records but it
    works better for organizations with IdPs, especially universities. 
  
  Passing an option of `ror: false` will skip ROR lookups, which can be slow.
  
  """
  ## Use extra data to enhance records - ROR, country data, etc. Patch/overlays can go here
  @spec enhance(enum :: Enumerable.t(), opts :: keyword()) :: Enumerable.t()
  def enhance(enum, opts \\ []) do
    Process.enhance(enum, opts)
  end

  @doc """
  Will attempt to find logos for a list of organizations.
  
  At present it tries to find suitable Apple Touch icons at URLs associated with the Organization. Only the 
    logo's URL is stored.
  """
  @spec add_logos(enum :: Enumerable.t(), opts :: keyword()) :: Enumerable.t()
  def add_logos(enum, opts \\ [force: false]) do
    Process.add_logos(enum, opts)
  end

  @doc """
  Adds a URI-based ID to the Organization struct 
  
  """
  @spec add_uris(enum :: Enumerable.t(), opts :: keyword()) :: Enumerable.t()
  def add_uris(enum, opts \\ []) do
    Process.add_uris(enum, opts)
  end
  
  @doc """
  Applies the default patches to a list of Organizations.
  
  These patches are absolutely not guaranteed to fix all issues or even to not add any, but they should help. For
    serious production use it is better to gradually build your own patch file and apply it using `patch!/2`
  """
  @spec patch!(enum :: Enumerable.t()) :: Enumerable.t()
  def patch!(enum) do
    Patch.patch!(enum, Patch.default_patch_location())
  end

  @doc """
  Applies the specified patch data to a list of Organizations.
  
  The patch file to use can be specified using a filename, a list of patch records (see the JSON file in priv/ 
    for an example) or a list of patch records converted into a map with IDs as keys. Usually it's best to 
    save your patches as a JSON file and specify it with a filename.
  """
  @spec patch!(enum :: Enumerable.t(), source :: binary() | map() | list(), opts :: keyword()) :: Enumerable.t()
  def patch!(enum, source, _opts \\ []) do
    Patch.patch!(enum, source)
  end

  @doc """
  Writes a list of Organization structs to disk, at the specified path/filename
  
  Currently you can't conveniently reload these into SmeeOrgs so this function is only useful for
    exporting the data to use with other software or to review. 
  
  """
  @spec dump(enum :: Enumerable.t(), filename :: binary(), opts :: keyword()) :: Enumerable.t()
  def dump(enum, filename \\ "orgs_dump.json", opts \\ []) do
    Process.dump(enum, filename, opts)
  end

end
