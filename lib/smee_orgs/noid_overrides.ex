defmodule SmeeOrgs.NoidOverrides do

  def builtin(noid) do
     noid
     |> prefix()
     |> String.reverse()
     |> suffix()
  end
  
  def prefix("online_computer_library_center" <> _) do
    "oclc"
  end

  def prefix("oclc_" <> _) do
    "oclc"
  end

  def prefix("consortium_garr") do
    "garr"
  end

  def prefix("prod_idp_in_the_cloud_project_garr") do
    "garr"
  end

  def prefix("géant" <> _) do
    "geant"
  end

  def prefix("geant" <> _) do
    "geant"
  end

  def prefix("ethiopian_education_and_research_network_" <> _) do
    "ethiopian_education_and_research_network"
  end

  def prefix("eduroam_" <> _ ) do
    "eduroam"
  end

  def prefix("eduteams_" <> _) do
    "eduteams"
  end

  def prefix("ebsco_" <> _) do
    "ebsco"
  end

  def prefix("deic_" <> _) do
    "deic"
  end

  def prefix("deicdk") do
    "deic"
  end

  def prefix("dar_alhekma_university_2") do
    "dar_alhekma_university"
  end

  def prefix("cstcloud_" <> _) do
    "cstcloud"
  end

  def prefix("géant_" <> _) do
    "géant"
  end

  def prefix("heanet_" <> _) do
    "heanet"
  end

  def prefix("inflibnet_" <> _) do
    "inflibnet"
  end

  def prefix("its_learning_" <> _) do
    "itslearning"
  end

  def prefix("itslearning_" <> _) do
    "itslearning"
  end

  def prefix("jisc_" <> _) do
    "jisc"
  end

  def prefix("maeen_" <> _) do
    "maeen"
  end

  def prefix("qualtrics_" <> _) do
    "qualtrics"
  end

  def prefix("redclara_" <> _) do
    "redclara"
  end

  def prefix("semantico_" <> _) do
    "semantico"
  end

  def prefix("simplyprint_" <> _) do
    "simplyprint"
  end

  def prefix("stiftung_" <> _) do
    "stiftung"
  end

  def prefix("surfnet") do
    "surf"
  end

  def prefix("turnitin_" <> _) do
    "turnitin"
  end

  def prefix("ubuntunet_alliance_" <> _) do
    "ubuntunet_alliance"
  end

  def prefix("association_uran") do
    "uran"
  end

  def prefix("uran_" <> _) do
    "uran"
  end

  def prefix("ss_cyril_and_methodium_university_in_skopje") do
    "ss_cyril_and_methodius_university_in_skopje"
  end

  def prefix("somaliren") do
    "somali_research_and_education_network"
  end

  def prefix("bbc_studios_distribution") do
    "british_broadcasting_corporation"
  end

  def prefix(noid) do
    noid
  end

  def suffix("ejpoks_ni_ytisrevinu_suidohtem_dna_liryc" <> _) do
    "ss_cyril_and_methodius_university_in_skopje"
  end

  def suffix("ejpoks_ni_suidohtem_dna_liryc" <> _) do
    "ss_cyril_and_methodius_university_in_skopje"
  end

  def suffix(noid) do
    String.reverse(noid)
  end

end
