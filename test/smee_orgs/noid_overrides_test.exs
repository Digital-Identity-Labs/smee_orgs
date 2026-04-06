defmodule NoidOverridesTest do
  use ExUnit.Case
  
  alias SmeeOrgs.NoidOverrides
  
  describe "builtin/1" do
    
    test "overrides various OCLC" do
      assert "oclc" = NoidOverrides.builtin("online_computer_library_center")
      assert "oclc" = NoidOverrides.builtin("oclc_various")
    end

    test "overrides various Geant" do
      assert "geant" = NoidOverrides.builtin("géant")
      assert "geant" = NoidOverrides.builtin("géantsomething")
      assert "geant" = NoidOverrides.builtin("geantsomething")
      assert "geant" = NoidOverrides.builtin("eduteams_thing")
      assert "geant" = NoidOverrides.builtin("eduteams")
    end

    test "overrides various GARR" do
      assert "garr" = NoidOverrides.builtin("consortium_garr")
      assert "garr" = NoidOverrides.builtin("prod_idp_in_the_cloud_project_garr")
    end

    test "overrides various EBSCO" do
      assert "ebsco" = NoidOverrides.builtin("ebsco_thing")
    end

    test "overrides various Eduroam" do
      assert "XXX" = NoidOverrides.builtin("XXX")
    end

    test "overrides various Ethiopian Education and Research Network" do
      assert "ethiopian_education_and_research_network" = NoidOverrides.builtin("ethiopian_education_and_research_network_")
    end

    test "overrides various DEIC" do
      assert "deic" = NoidOverrides.builtin("deic_thing")
      assert "deic" = NoidOverrides.builtin("deicdk")
    end

    test "overrides various dar_alhekma_university" do
      assert "dar_alhekma_university" = NoidOverrides.builtin("dar_alhekma_university_2")
    end

    test "overrides various CSTCloud" do
      assert "cstcloud" = NoidOverrides.builtin("cstcloud_")
    end

    test "overrides various Heanet" do
      assert "heanet" = NoidOverrides.builtin("heanet_")
    end

    test "overrides various inflibnet" do
      assert "inflibnet" = NoidOverrides.builtin("inflibnet_")
    end

    test "overrides various its_learning" do
      assert "itslearning" = NoidOverrides.builtin("its_learning_")
      assert "itslearning" = NoidOverrides.builtin("itslearning_")
    end

    test "overrides various Jisc" do
      assert "jisc" = NoidOverrides.builtin("jisc_thing")
    end

    test "overrides various maeen" do
      assert "maeen" = NoidOverrides.builtin("maeen_")
    end

    test "overrides various qualtrics" do
      assert "qualtrics" = NoidOverrides.builtin("qualtrics_")
    end

    test "overrides various redclara" do
      assert "redclara" = NoidOverrides.builtin("redclara_")
    end

    test "overrides various simplyprint" do
      assert "simplyprint" = NoidOverrides.builtin("simplyprint_")
    end

    test "overrides various stiftung" do
      assert "stiftung" = NoidOverrides.builtin("stiftung_")
    end

    test "overrides various surfnet" do
      assert "surf" = NoidOverrides.builtin("surfnet")
    end


    test "overrides various turnitin" do
      assert "turnitin" = NoidOverrides.builtin("turnitin_")
    end

    test "overrides various ubuntunet_alliance" do
      assert "ubuntunet_alliance" = NoidOverrides.builtin("ubuntunet_alliance_")
    end

    test "overrides various uran" do
      assert "uran" = NoidOverrides.builtin("association_uran")
      assert "uran" = NoidOverrides.builtin("uran_thing")
      assert "uran" = NoidOverrides.builtin("filesender_service")
    end

    test "overrides various ipil" do
      assert "ipil" = NoidOverrides.builtin("elearning_platform")
    end

    test "overrides various greek_universities_network" do
      assert "greek_universities_network" = NoidOverrides.builtin("greek_university_network")
    end

    test "overrides various ss_cyril_and_methodius_university_in_skopje" do
      assert "ss_cyril_and_methodius_university_in_skopje" = NoidOverrides.builtin("ss_cyril_and_methodium_university_in_skopje")
      assert "ss_cyril_and_methodius_university_in_skopje" = NoidOverrides.builtin("something_at_cyril_and_methodius_university_in_skopje")
      assert "ss_cyril_and_methodius_university_in_skopje" = NoidOverrides.builtin("something_at_cyril_and_methodius_in_skopje")
    end

    test "overrides various somali_research_and_education_network" do
      assert "somali_research_and_education_network" = NoidOverrides.builtin("somaliren")
    end

    test "overrides various british_broadcasting_corporation" do
      assert "british_broadcasting_corporation" = NoidOverrides.builtin("bbc_studios_distribution")
    end

    test "overrides various canarie" do
      assert "canarie" = NoidOverrides.builtin("canarie_")
    end

    test "overrides various cesnet" do
      assert "cesnet" = NoidOverrides.builtin("cesnetthing")
    end

    test "overrides various clarivate" do
      assert "clarivate" = NoidOverrides.builtin("proquest")
      assert "clarivate" = NoidOverrides.builtin("ebooks_corporation")
      assert "clarivate" = NoidOverrides.builtin("ex_libris_thing")
      assert "clarivate" = NoidOverrides.builtin("refworks")
    end

    test "overrides various elsevier" do
      assert "elsevier" = NoidOverrides.builtin("elsevier_whatever")
    end

    test "overrides various access_group_peoplexd" do
      assert "access_group_peoplexd" = NoidOverrides.builtin("corehr_thing")
    end
    
    test "overrides various guru" do
      assert "guru" = NoidOverrides.builtin("guru_thing")
    end
    
    test "overrides various qs_unisolution" do
      assert "qs_unisolution" = NoidOverrides.builtin("e433")
    end
    
    test "overrides various research_and_education_network_for_uganda" do
      assert "research_and_education_network_for_uganda" = NoidOverrides.builtin("renu")
      assert "research_and_education_network_for_uganda" = NoidOverrides.builtin("research_and_education_for_uganda_renu")
    end
    
    test "overrides various ligoindia_scientific_collaboration" do
      assert "ligoindia_scientific_collaboration" = NoidOverrides.builtin("iucaa")
    end
    
    test "overrides various MPS" do
      assert "mps" = NoidOverrides.builtin("semantico")
      assert "mps" = NoidOverrides.builtin("semantico_thing")
      assert "mps" = NoidOverrides.builtin("highwire_press_inc")
    end
    
    test "overrides various Brill" do
      assert "brill" = NoidOverrides.builtin("brillcom")
      assert "brill" = NoidOverrides.builtin("walter_de_gruyter_gmbh_&_co_kg")
      assert "brill" = NoidOverrides.builtin("e190")
    end
    
    test "overrides various Sop" do
      assert "sop_hilmbauer_&_mauberger" = NoidOverrides.builtin("sop_hilmbauer_&_mauberger_gmbh_&_co_kg")
      assert "sop_hilmbauer_&_mauberger" = NoidOverrides.builtin("e370")
    end
    
    test "overrides various italian_national_institute_for_nuclear_physics" do
      assert "italian_national_institute_for_nuclear_physics" = NoidOverrides.builtin("national_institute_for_nuclear_physics")
      assert "italian_national_institute_for_nuclear_physics" = NoidOverrides.builtin("national_institute_for_nuclear_physics_infn")
    end
    
    test "overrides various evasys" do
      assert "evasys" = NoidOverrides.builtin("e540")
    end
    
    test "overrides various kif" do
      assert "kif" = NoidOverrides.builtin("kif_filesender")
    end
    
    test "overrides various e780" do
      assert "e780" = NoidOverrides.builtin("e692")
    end
    
    test "overrides various ghanaian_academic_and_research_network" do
      assert "ghanaian_academic_and_research_network" = NoidOverrides.builtin("garnetedugh")
    end
    
    test "overrides various greek_research_and_technology_network_grnet" do
      assert "greek_research_and_technology_network_grnet" = NoidOverrides.builtin("national_infrastructures_for_research_and_technology_grnet")
    end
    
    test "overrides various harvard" do
      assert "harvard" = NoidOverrides.builtin("harvard_")
      assert "harvard" = NoidOverrides.builtin("president_and_fellows_of_harvard_college")
    end
    
    test "overrides various kenya_education_network" do
      assert "kenya_education_network" = NoidOverrides.builtin("kenya_education_network_")
    end
    
    test "overrides various ma_group" do
      assert "ma_group" = NoidOverrides.builtin("ma_healthcare")
      assert "ma_group" = NoidOverrides.builtin("ma_education")
    end
    
    test "overrides various masaryk_university" do
      assert "masaryk_university" = NoidOverrides.builtin("loschmidt_laboratories")
    end
    
    test "overrides various niif_institute_national_information_infrastructure_development" do
      assert "niif_institute_national_information_infrastructure_development" = NoidOverrides.builtin("partner_sps")
    end
    
    test "overrides various politecnico_di_milano" do
      assert "politecnico_di_milano" = NoidOverrides.builtin("polimi")
    end

    test "overrides various wolters_kluwer_nv" do
      assert "wolters_kluwer_nv" = NoidOverrides.builtin("wolters_kluwer_united_states")
      assert "wolters_kluwer_nv" = NoidOverrides.builtin("kluwer_law_international")
      assert "wolters_kluwer_nv" = NoidOverrides.builtin("ovid_technologies")
    end
    



  end

  
end
