defmodule SmeeOrgs.Patch do

  @patch_defaults %{
    "match" => "noid",
    "priority" => 100
  }

  alias SmeeOrgs.Client


  def patch!(enum, patch_data) when is_list(patch_data) do
    patches = patch_data
              |> prepare_patches()

    enum
    |> Enum.map(fn org -> apply_patches(org, patches) end)

  end

  def patch!(enum, location) when is_binary(location) do
    patch!(enum, fetch!(location))
  end

  def patch!(_enum, _data) do
    raise "Patch can only be either a filename, URL or parsed patch data"
  end

  def diff!(org1, org2) do
    patches = Jsonpatch.diff(org1, org2, keys: :atoms)
    %{@patch_defaults | patch: patches}
  end

  def fetch!("http" <> _ = location) do
    Client.get!(location)
  end

  def fetch!(location) do
    File.read!(location)
    |> Jason.decode!()
  end

  def valid?(data) do
    true
  end

  def validate!(data) do
    if valid?(data), do: data, else: raise("Invalid patch data!")
  end

  def default_patch_location() do
    Path.join(Application.app_dir(:smee_orgs, "priv"), "patches/default.json")
  end

  ###################################

  defp apply_patches(org, patches) do

    matching_patches = Map.get(patches, "noid", %{})
                       |> Map.get(org.noid, [])
                       |> Enum.map(fn patch -> patch["patch"] end)

    Enum.reduce(matching_patches, org, fn patch, acc -> Jsonpatch.apply_patch!(patch, org, keys: :atoms) end)

  end

  defp prepare_patches(data) do
    data
    |> validate!()
    |> Enum.map(fn p -> Map.merge(@patch_defaults, p) end)
    |> Apex.ap()
    |> Enum.sort_by(fn item -> item["priority"] end)
    |> Enum.group_by(fn item -> item["match"] end, fn item -> item end)
    |> Enum.map(
         fn {match, items} -> {match, Enum.group_by(items, fn item -> item["when"] end, fn item -> item end)} end
       )
    |> List.flatten() # SMELL
    |> Map.new()
  end

end
