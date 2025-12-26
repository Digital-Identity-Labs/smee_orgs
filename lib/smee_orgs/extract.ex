defmodule SmeeOrgs.Extract do

  @moduledoc false

  alias __MODULE__
  alias Smee.Entity
  alias Smee.Metadata
  alias SmeeOrgs.XPaths
  alias SmeeOrgs.Utils
  alias SmeeOrgs.Organization

  def select_name(names, lang \\ "en") do
    names
    |> Utils.select_lang(lang)
  end

  def select_domain(domains) do
    domains
    |> Enum.map(fn {lang, v} -> v end)
    |> List.first()
  end

  def one(entity) do
    data = XPaths.extract_org(entity.uri, entity.metadata_uri, Entity.xdoc(entity))
    Organization.new(select_name(data[:names]), select_domain(data[:urls]), data)
  end

  ## Need to implement other data type handlers
  #@spec stream(input :: Entity.t() | Metadata.t() | list() | %Stream{} | function(), options :: keyword()) :: %Stream{} | function()
  def stream(input, options \\ [])
  def stream(stream, options) when is_struct(stream, Stream) or is_function(stream) do
    stream
    |> Stream.map(fn e -> one(e) end)
  end

  #    def stream(input, options \\ [])
  #    def stream(stream, options) when is_struct(stream, Stream) or is_function(stream) do
  #
  #      options = Keyword.merge([concurrency: 5, timeout: 1000], options)
  #
  #      stream
  #      |> Task.async_stream(
  #           fn e -> Extract.stream(e, options) end,
  #           ordered: false,
  #           max_concurrency: options[:concurrency],
  #           timeout: options[:timeout],
  #           on_timeout: :kill_task
  #         )
  #      |> Stream.reject(fn {k, _v} -> k in [:exit, :error] end)
  #      |> Stream.map(fn {:ok, list} -> list end)
  #      |> Stream.flat_map(fn ls -> ls end)
  #    end
  #
  #    def stream(%Entity{} = entity, options) do
  #      Entity.xdoc(entity)
  #      |> XPaths.extract_org()
  #      |> Apex.ap()
  #      |> Map.get(:logos)
  #      |> Stream.concat([])
  #      |> Stream.map(
  #           fn l ->
  #             Logo.get(
  #               entity.uri,
  #               l[:url],
  #               l[:role],
  #               lang: l[:lang],
  #               uri_hash: entity.uri_hash,
  #               tags: options[:tags],
  #               truncate: options[:truncate]
  #             )
  #           end
  #         )
  #      |> Stream.reject(fn l -> is_nil(l) end)
  #      |> Stream.filter(fn l -> Logo.valid?(l) end)
  #      |> Fallback.ensure(entity, options)
  #      |> Pick.pick(options[:pick_by], options[:pick])
  #      |> Stream.concat([])
  #    end
  #
  #    def stream(%Metadata{} = metadata, options) do
  #      metadata
  #      |> Metadata.stream_entities()
  #      |> stream(options)
  #    end
  #
  #    def stream(entities, options) when is_list(entities) do
  #      Stream.concat(entities, [])
  #      |> stream(options)
  #    end
  #
  #    @spec list(input :: Entity.t() | Metadata.t() | list() | %Stream{}, options :: keyword()) :: list(Logo.t())
  #    def list(input, options \\ []) do
  #      stream(input, options)
  #      |> Enum.to_list()
  #    end
  #
  #    @spec one(input :: Entity.t(), options :: keyword()) :: Logo.t() | nil
  #    def one(input, options \\ [])
  #    def one(%Entity{} = input, options) do
  #      input
  #      |> list(Keyword.merge([pick_by: :best, pick: 1], options))
  #      |> List.first()
  #    end
  #
  #    def one(%Metadata{} = input, options) do
  #      opts = Keyword.merge([pick_by: :best, pick: 1, retries: 3], options)
  #      random_logo = Metadata.random_entity(input)
  #                    |> one(opts)
  #
  #      if random_logo do
  #        random_logo
  #      else
  #        stream(input, opts)
  #        |> Stream.take(1)
  #        |> Enum.to_list()
  #        |> List.first()
  #      end
  #
  #    end
  #
  #    def one(_, _) do
  #      raise "Can only extract for One from a single Entity or Metadata struct, not a list or stream, etc!"
  #    end


end
