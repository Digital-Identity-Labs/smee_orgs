defmodule SmeeOrgs.Patch do

  @moduledoc false
  
  @patch_defaults %{
    "match" => "noid",
    "priority" => 100,
    "patch" => []
  }

  alias __MODULE__
  alias SmeeOrgs.Organization
  alias SmeeOrgs.Client
  alias SmeeOrgs.Normalize

  @spec patch!(enum :: Enumerable.t(), data :: :default | list() | map() | binary()) :: Enumerable.t()
  def patch!(enum, :default) do
    Patch.patch!(enum, Patch.default_patch_location())
  end

  def patch!(enum, patch_data) when is_list(patch_data) do
    patches = patch_data
              |> prepare_patches()

    patch!(enum, patches)

  end

  def patch!(enum, patches) when is_map(patches) do
    enum
    |> Enum.map(fn org -> apply_patches(org, patches) end)
  end

  def patch!(enum, location) when is_binary(location) do
    patch!(enum, fetch!(location))
  end

  def patch!(_enum, _data) do
    raise "Patch can only be either a filename, URL or parsed patch data"
  end

  @spec diff!(org1 :: Jsonpatch.Types.json_container(), org2 :: Jsonpatch.Types.json_container()) :: map()
  def diff!(org1, org2) do
    patches = Jsonpatch.diff(Map.from_struct(org1), Map.from_struct(org2))
    %{@patch_defaults | "patch" => patches}
  end

  @spec fetch!(location :: binary()) :: list()
  def fetch!("http" <> _ = location) do
    data = Client.get!(location)
    if is_binary(data), do: Jason.decode!(data), else: data # work around badly typed responses
  end

  def fetch!("file:" <> _ = location) do
    location
    |> String.replace_leading("file:", "")
    |> File.read!()
    |> Jason.decode!()
  end
  
  def fetch!(location) do
    File.read!(location)
    |> Jason.decode!()
  end

  @spec valid?(data :: Enumerable.t()) :: boolean()
  def valid?(patch_data) do
    ## TODO: We could probably do with using a JSON schema here 
    cond do
      !is_list(patch_data) -> false
      !Enum.all?(patch_data, fn x -> is_map(x) end) -> false
      true -> true
    end
  end

  @spec validate!(data :: Enumerable.t()) :: Enumerable.t()
  def validate!(data) do
    if !valid?(data), do: raise("Invalid patch data!")
    data
  end

  @spec default_patch_location() :: binary()
  def default_patch_location() do
    Path.join(Application.app_dir(:smee_orgs, "priv"), "patches/default.json")
  end

  @spec prepare_patches(data :: Enumerable.t()) :: map()
  def prepare_patches(data) do
    data
    |> validate!()
    |> Enum.map(fn p -> Map.merge(@patch_defaults, p) end)
    |> Enum.sort_by(fn item -> item["priority"] end)
    |> Enum.group_by(fn item -> item["match"] end, fn item -> item end)
    |> Enum.map(
         fn {match, items} -> {match, Enum.group_by(items, fn item -> item["when"] end, fn item -> item end)} end
       )
    |> List.flatten() # SMELL
    |> Map.new()
  end

  ###################################

  @spec apply_patches(org :: SmeeOrgs.Organization.t(), patches :: Enumerable.t()) :: Enumerable.t()
  defp apply_patches(org, patches) do

    matching_patches = Map.get(patches, "noid", %{})
                       |> Map.get(org.noid, [])
                       |> Enum.map(fn patch -> patch["patch"] end)

    patched = Enum.reduce(
      matching_patches,
      org,
      fn patch, _acc -> Jsonpatch.apply_patch!(patch, org, keys: :atoms) end
    )
     
    %{patched | type: Normalize.type(patched.type) }
    

  end

end
