defmodule SmeeOrgs.Tidy do

  alias SmeeOrgs.Normalize
  alias SmeeOrgs.Organization
  alias SmeeOrgs.Utils

  @dfn "https://www.aai.dfn.de"
  @service_hints ["Moodle", "SP ", "VLE ", "IdP", "Test ", " test ", "Service Provider ", "SSO "]
  @censor ["Moodle", "VLE", "MOOC Edvance provided by ", " - MOODLE LMS for MOOCs"]

  def all(org) do
    org
    |> dfn_code_names()
    |> swap_bad_names()
    |> edit_bad_names()
    |> not_provided_by()
    |> assume_type()
  end

  def dfn_code_names(org) do
    if Enum.member?(org.registrars, @dfn) do
      Map.put(org, :names, Map.get(org, :displaynames))
    else
      org
    end

  end

  def assume_type(
        %{
          type: :unknown,
          displaynames: %{
            "en" => name
          }
        } = org
      ) do

    assume_type_prefix(org, name)
    |> assume_type_rsuffix(String.reverse(name))
  end

  def assume_type(org) do
    org
  end

  def assume_type_prefix(org, "University of " <> _) do
    %{org | type: :education}
  end

  def assume_type_prefix(org, "Univerza" <> _) do
    %{org | type: :education}
  end

  def assume_type_prefix(org, "Universidad " <> _) do
    %{org | type: :education}
  end

  def assume_type_prefix(org, "Universitat " <> _) do
    %{org | type: :education}
  end

  def assume_type_prefix(org, "Universiteit " <> _) do
    %{org | type: :education}
  end

  def assume_type_prefix(org, "Institut" <> _) do
    %{org | type: :education}
  end

  def assume_type_prefix(org, "Universiti " <> _) do
    %{org | type: :education}
  end

  def assume_type_prefix(org, "Ecole " <> _) do
    %{org | type: :education}
  end

  def assume_type_prefix(org, "Université " <> _) do
    %{org | type: :education}
  end

  def assume_type_prefix(org, "Univerza " <> _) do
    %{org | type: :education}
  end

  def assume_type_prefix(org, "National " <> _) do
    %{org | type: :facility}
  end

  def assume_type_prefix(org, "eduID. " <> _) do
    %{org | type: :other}
  end

  def assume_type_prefix(org, _) do
    org
  end

  def assume_type_rsuffix(org, "dtL" <> _)   do
    %{org | type: :company}
  end

  def assume_type_rsuffix(org, "CLP" <> _)  do
    %{org | type: :company}
  end

  def assume_type_rsuffix(org, "detmiL" <> _)   do
    %{org | type: :company}
  end

  def assume_type_rsuffix(org, "cnI" <> _)   do
    %{org | type: :company}
  end

  def assume_type_rsuffix(org, ".cnI" <> _)  do
    %{org | type: :company}
  end

  def assume_type_rsuffix(org, "HbmG" <> _)  do
    %{org | type: :company}
  end

  def assume_type_rsuffix(org, "ytisrevinU" <> _) do
    %{org | type: :education}
  end

  def assume_type_rsuffix(org, "yrotarobaL" <> _) do
    %{org | type: :facility}
  end

  def assume_type_rsuffix(org, _) do
    org
  end

  def swap_bad_names(%{displaynames: %{"en" => name1}, names: %{"en" => name2}} = org) do
    if String.contains?(name1, @service_hints) and !String.contains?(name2, @service_hints) do
      %{org | displaynames: org.names}
    else
      org
    end
  end

  def edit_bad_names(%{displaynames: %{"en" => name}} = org) do
    if String.contains?(name, @service_hints) do

      new_names = Map.get(org, :displaynames, %{})
      |> Enum.map(fn {k, v} -> {k, String.replace(v, @censor, "") |> String.trim()} end)
      |> Map.new()
      %{org | displaynames: new_names}
    else
      org
    end
  end

  def not_provided_by(%{displaynames: %{"en" => name}} = org) do
    if String.contains?(name, "provided by") do
      new_names = Map.get(org, :displaynames, %{})
                  |> Enum.map(fn {k, v} -> {k, Regex.replace(~r/(\A.*provided by)(.*)\Z/, v, "\\2") |> String.trim()} end)
                  |> Map.new()
      %{org | displaynames: new_names}
    else
      org
    end
  end

end