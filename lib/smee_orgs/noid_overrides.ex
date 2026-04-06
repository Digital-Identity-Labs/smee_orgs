defmodule SmeeOrgs.NoidOverrides do

  @moduledoc false

  @spec builtin(noid :: binary()) :: binary()
  def builtin(noid) do
    noid
    |> prefix()
    |> String.reverse()
    |> suffix()
  end

  @spec prefix(noid :: binary()) :: binary()
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

  def prefix("eduteams_" <> _) do
    "geant"
  end

  def prefix("eduteams") do
    "geant"
  end

  def prefix("ethiopian_education_and_research_network_" <> _) do
    "ethiopian_education_and_research_network"
  end

  def prefix("eduroam_" <> _) do
    "eduroam"
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

  def prefix("dar_alhekma_university_" <> _) do
    "dar_alhekma_university"
  end

  def prefix("cstcloud_" <> _) do
    "cstcloud"
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

  def prefix("filesender_service") do
    "uran"
  end

  def prefix("elearning_platform") do
    "ipil"
  end

  def prefix("greek_university_network") do
    "greek_universities_network"
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

  def prefix("canarie_" <> _) do
    "canarie"
  end

  def prefix("cesnet" <> _) do
    "cesnet"
  end

  def prefix("proquest") do
    "clarivate"
  end

  def prefix("ebooks_corporation") do
    "clarivate"
  end

  def prefix("ex_libris_" <> _) do
    "clarivate"
  end

  def prefix("refworks") do
    "clarivate"
  end

  def prefix("elsevier_" <> _) do
    "elsevier"
  end

  def prefix("corehr_" <> _) do
    "access_group_peoplexd"
  end

  def prefix("guru_" <> _) do
    "guru"
  end

  def prefix("e433") do
    "qs_unisolution"
  end

  def prefix("renu") do
    "research_and_education_network_for_uganda"
  end

  def prefix("research_and_education_for_uganda_renu") do
    "research_and_education_network_for_uganda"
  end

  def prefix("iucaa") do
    "ligoindia_scientific_collaboration"
  end

  def prefix("semantico") do
    "mps"
  end

  def prefix("semantico_" <> _) do
    "mps"
  end

  def prefix("highwire_press_inc") do
    "mps"
  end

  def prefix("brillcom") do
    "brill"
  end

  def prefix("e190") do
    "brill"
  end

  def prefix("walter_de_gruyter_gmbh_&_co_kg") do
    "brill"
  end

  def prefix("sop_hilmbauer_&_mauberger_gmbh_&_co_kg") do
    "sop_hilmbauer_&_mauberger"
  end

  def prefix("e370") do
    "sop_hilmbauer_&_mauberger"
  end

  def prefix("national_institute_for_nuclear_physics") do
    "italian_national_institute_for_nuclear_physics"
  end

  def prefix("national_institute_for_nuclear_physics_infn") do
    "italian_national_institute_for_nuclear_physics"
  end

  def prefix("e540") do
    "evasys"
  end

  def prefix("kif_filesender") do
    "kif"
  end

  def prefix("e692") do
    "e780"
  end

  def prefix("garnetedugh") do
    "ghanaian_academic_and_research_network"
  end

  def prefix("national_infrastructures_for_research_and_technology_grnet") do
    "greek_research_and_technology_network_grnet"
  end

  def prefix("harvard_"  <> _) do
    "harvard"
  end

  def prefix("president_and_fellows_of_harvard_college") do
    "harvard"
  end

  def prefix("kenya_education_network_" <> _) do
    "kenya_education_network"
  end

  def prefix("ma_healthcare") do
    "ma_group"
  end

  def prefix("ma_education") do
    "ma_group"
  end

  def prefix("loschmidt_laboratories") do
    "masaryk_university"
  end

  def prefix("ics_muni") do
    "masaryk_university"
  end

  def prefix("partner_sps") do
    "niif_institute_national_information_infrastructure_development"
  end

  def prefix("polimi") do
    "politecnico_di_milano"
  end

  def prefix("wolters_kluwer_united_states") do
    "wolters_kluwer_nv"
  end

  def prefix("kluwer_law_international") do
    "wolters_kluwer_nv"
  end

  def prefix("ovid_technologies") do
    "wolters_kluwer_nv"
  end

  def prefix(noid) do
    noid
  end

  @spec suffix(noid :: binary()) :: binary()
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
