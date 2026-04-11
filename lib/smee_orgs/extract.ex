defmodule SmeeOrgs.Extract do

  @moduledoc false

  alias Smee.Entity
  alias Smee.Metadata
  alias SmeeOrgs.XPaths
  alias SmeeOrgs.Utils
  alias SmeeOrgs.Organization

  @spec select_name(names :: map(), lang :: binary()) :: binary()
  def select_name(names, lang \\ "en") do
    name = names
    |> Utils.select_lang(lang)
    if is_nil(name), do: "unknown", else: name
  end

  @spec select_domain(domains :: map()) :: binary()
  def select_domain(domains) do
    domains
    |> Enum.map(fn {_lang, v} -> v end)
    |> List.first()
  end

  @spec one(entity :: Entity.t()) :: Organization.t()
  def one(entity) do
    data = XPaths.extract_org(entity.uri, entity.metadata_uri, Entity.xdoc(entity))
    Organization.new(select_name(data[:names]), select_domain(data[:urls]), data)
  end

  ## Need to implement other data type handlers
  @spec stream(input :: Entity.t() | Metadata.t() | list() | %Stream{} | function(), options :: keyword()) :: %Stream{} | function()
  def stream(input, options \\ [])
  def stream(stream, _options) when is_struct(stream, Stream) or is_function(stream) do
    stream
    |> Stream.map(fn e -> one(e) end)
  end

  def stream(%Entity{} = entity, _opts) do
    one(entity)
    |> List.wrap()
    |> Stream.concat([])
  end
  
  def stream(%Metadata{} = metadata, opts) do
    metadata
    |> Metadata.stream_entities()
    |> stream(opts)
  end

  def stream(entities, opts) when is_list(entities) do
    Stream.concat(entities, [])
    |> stream(opts)
  end

  def stream(_other, _opts) do
    raise "Cannot extract Organization structs from this input!"
  end
  
end
