defmodule SmeeOrgs.NoidOverrides do

  def builtin("online_computer_library_center" <> _) do
    "oclc"
  end

  def builtin("oclc_" <> _) do
    "oclc"
  end

  def builtin("consortium_garr") do
    "garr"
  end

  def builtin("prod_idp_in_the_cloud_project_garr") do
    "garr"
  end

  def builtin("geant" <> _) do
    "geant"
  end

  def builtin("ethiopian_education_and_research_network_" <> _) do
    "ethiopian_education_and_research_network"
  end

  def builtin("eduroam_" <> _ ) do
    "eduroam"
  end

  def builtin("eduteams_" <> _) do
    "eduteams"
  end

  def builtin("ebsco_" <> _) do
    "ebsco"
  end

  def builtin("deic_" <> _) do
    "deic"
  end

  def builtin("deicdk") do
    "deic"
  end

  def builtin("dar_alhekma_university_2") do
    "dar_alhekma_university"
  end

  def builtin("cstcloud_" <> _) do
    "cstcloud"
  end

  def builtin("géant_" <> _) do
    "géant"
  end

  def builtin("heanet_" <> _) do
    "heanet"
  end

  def builtin("inflibnet_" <> _) do
    "inflibnet"
  end

  def builtin("its_learning_" <> _) do
    "itslearning"
  end

  def builtin("itslearning_" <> _) do
    "itslearning"
  end

  def builtin("jisc_" <> _) do
    "jisc"
  end

  def builtin("maeen_" <> _) do
    "maeen"
  end

  def builtin("qualtrics_" <> _) do
    "qualtrics"
  end

  def builtin("redclara_" <> _) do
    "redclara"
  end

  def builtin("semantico_" <> _) do
    "semantico"
  end

  def builtin("simplyprint_" <> _) do
    "simplyprint"
  end

  def builtin("stiftung_" <> _) do
    "stiftung"
  end

  def builtin("surfnet") do
    "surf"
  end

  def builtin("turnitin_" <> _) do
    "turnitin"
  end

  def builtin("ubuntunet_alliance_" <> _) do
    "ubuntunet_alliance"
  end

  def builtin(noid) do
    noid
  end

end
