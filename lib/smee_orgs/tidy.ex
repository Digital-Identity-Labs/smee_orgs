defmodule SmeeOrgs.Tidy do

  @moduledoc false

  @dfn "https://www.aai.dfn.de"
  @service_hints ["Moodle", "SP ", "VLE ", "IdP", "Test ", " test ", "Service Provider ", "SSO "]
  @censor ["Moodle", "VLE", "MOOC Edvance provided by ", " - MOODLE LMS for MOOCs"]
  
  @spec all(org :: SmeeOrgs.Organization.t()) :: SmeeOrgs.Organization.t()
  def all(org) do
    org
    |> dfn_code_names()
    |> swap_bad_names()
    |> edit_bad_names()
    |> not_provided_by()
    |> assume_type()
  end

  @spec dfn_code_names(org :: SmeeOrgs.Organization.t()) :: SmeeOrgs.Organization.t()
  def dfn_code_names(org) do
    if Enum.member?(org.registrars, @dfn) do
      Map.put(org, :names, Map.get(org, :displaynames, %{}))
    else
      org
    end

  end

  @spec assume_type(org :: SmeeOrgs.Organization.t()) :: SmeeOrgs.Organization.t()
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

  @spec swap_bad_names(org :: SmeeOrgs.Organization.t()) :: SmeeOrgs.Organization.t()
  def swap_bad_names(%{displaynames: %{"en" => name1}, names: %{"en" => name2}} = org) do
    if String.contains?(name1, @service_hints) and !String.contains?(name2, @service_hints) do
      %{org | displaynames: org.names}
    else
      org
    end
  end

  def swap_bad_names(org) do
    org
  end

  @spec edit_bad_names(org :: SmeeOrgs.Organization.t()) :: SmeeOrgs.Organization.t()
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

  def edit_bad_names(org) do
    org
  end

  @spec not_provided_by(org :: SmeeOrgs.Organization.t()) :: SmeeOrgs.Organization.t()
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

  def not_provided_by(org) do
    org
  end

  #############################################################


  @spec assume_type_prefix(org :: SmeeOrgs.Organization.t(), prefix :: binary()) :: SmeeOrgs.Organization.t()
  defp assume_type_prefix(org, "University of " <> _) do
    %{org | type: :education}
  end

  defp assume_type_prefix(org, "Univerza" <> _) do
    %{org | type: :education}
  end

  defp assume_type_prefix(org, "Universidad " <> _) do
    %{org | type: :education}
  end

  defp assume_type_prefix(org, "Universitat " <> _) do
    %{org | type: :education}
  end

  defp assume_type_prefix(org, "Universität " <> _) do
    %{org | type: :education}
  end
  
  defp assume_type_prefix(org, "Universiteit " <> _) do
    %{org | type: :education}
  end

  defp assume_type_prefix(org, "Institut" <> _) do
    %{org | type: :education}
  end

  defp assume_type_prefix(org, "Universiti " <> _) do
    %{org | type: :education}
  end

  defp assume_type_prefix(org, "Ecole " <> _) do
    %{org | type: :education}
  end

  defp assume_type_prefix(org, "Université " <> _) do
    %{org | type: :education}
  end

  defp assume_type_prefix(org, "Univerza " <> _) do
    %{org | type: :education}
  end

  defp assume_type_prefix(org, "National " <> _) do
    %{org | type: :facility}
  end

  defp assume_type_prefix(org, "eduID." <> _) do
    %{org | type: :other}
  end

  defp assume_type_prefix(org, _) do
    org
  end

  @spec assume_type_rsuffix(org :: SmeeOrgs.Organization.t(), rsuffix :: binary()) :: SmeeOrgs.Organization.t()
  defp assume_type_rsuffix(org, "dtL" <> _)   do
    %{org | type: :company}
  end

  defp assume_type_rsuffix(org, "CLP" <> _)  do
    %{org | type: :company}
  end

  defp assume_type_rsuffix(org, "detimiL" <> _)   do
    %{org | type: :company}
  end

  defp assume_type_rsuffix(org, "cnI" <> _)   do
    %{org | type: :company}
  end

  defp assume_type_rsuffix(org, ".cnI" <> _)  do
    %{org | type: :company}
  end

  defp assume_type_rsuffix(org, "HbmG" <> _)  do
    %{org | type: :company}
  end

  defp assume_type_rsuffix(org, "ytisrevinU" <> _) do
    %{org | type: :education}
  end

  defp assume_type_rsuffix(org, "yrotarobaL" <> _) do
    %{org | type: :facility}
  end

  defp assume_type_rsuffix(org, _) do
    org
  end

end