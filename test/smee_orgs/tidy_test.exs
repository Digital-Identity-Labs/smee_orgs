defmodule TidyTest do
  use ExUnit.Case

  alias SmeeOrgs.Tidy
  alias SmeeOrgs.Organization

  describe "all/1" do

  end

  describe "dfn_code_names/1" do

    test "replaces DFN style code names with displaynames in DFN-registered entities" do
      assert %Organization{
               noid: "e1158",
               names: %{
                 "de" => "Universität Bayreuth"
               }
             } = Tidy.dfn_code_names(
               %Organization{
                 noid: "e1158",
                 names: %{
                   "de" => "e1158"
                 },
                 base_domain: "uni-bayreuth.de",
                 displaynames: %{
                   "de" => "Universität Bayreuth"
                 },
                 registrars: ["https://www.aai.dfn.de"]
               }
             )
    end

    test "ignores other federations" do
      assert %Organization{
               noid: "e1158",
               names: %{
                 "de" => "e1158"
               },
             } = Tidy.dfn_code_names(
               %Organization{
                 noid: "e1158",
                 names: %{
                   "de" => "e1158"
                 },
                 base_domain: "uni-bayreuth.de",
                 displaynames: %{
                   "de" => "Universität Bayreuth"
                 },
                 registrars: ["https://www.example.org"]
               }
             )
    end

  end

  describe "assume_type/1" do

    test "doesn't change anything unless the type is already :unknown" do
      assert %Organization{
               type: :company
             } = Tidy.assume_type(
               %Organization{
                 noid: "example",
                 type: :company,
                 base_domain: "example.com",
                 displaynames: %{
                   "de" => "example_com"
                 }
               }
             )
    end

    test "Various universities get the right type based on their name" do

      [
        "Universität Place",
        "University of Place",
        "Univerza",
        "Universidad ",
        "Universitat ",
        "Universiteit ",
        "Institut",
        "Universiti ",
        "Ecole ",
        "Université ",
        "Univerza ",
        "Place University",
        "Place College",
        "Place School",
        "Something SS",
        "Something College of FE",
        "Politecnico of Bari",
        "Politehnica University Timisoara",
        "Politeknik Bagan Datuk ",
        "Polytechnic Institute of Beja",
        "Pontificia Universidad Católica del Ecuador Quito",
        "Univerza v Ljubljani Medicinska fakulteta",
        "Academy of Something",
        "Centro Something",
        "China University Something",
        "American University Something",
        "Coleg Gwent",
        "College of Something",
        "The College of Something Else",
        "Escola Superior Agrária de Viseu",
        "Institut Agro Dijon",
        "Institute for Something",
        "Institute of Something",
        "Korea Institute of Something",
        "Academy of Something"
      ]
      |> Enum.each(
           fn name ->

             assert %Organization{
                      type: :education
                    } = Tidy.assume_type(
                      %Organization{
                        noid: "placeholder",
                        type: :unknown,
                        displaynames: %{
                          "en" => name
                        }
                      }
                    )

           end
         )
    end

    test "Various businesses get the right type based on their name" do

      [
        "Business Ltd",
        "Business PLC",
        "Business Limited",
        "Business Inc",
        "Business GmbH",
        "ProQuest LLC",
        "Something Incorporated",
        "Something Company",
        "Something Plc",
        "Something Plc",
        "Something Corporation"
      ]
      |> Enum.each(
           fn name ->
             assert %Organization{
                      type: :company,
                      displaynames: %{
                        "en" => ^name
                      }
                    } = Tidy.assume_type(
                      %Organization{
                        noid: "placeholder",
                        type: :unknown,
                        displaynames: %{
                          "en" => name
                        }
                      }
                    )

           end
         )
    end

    test "And various other types are detected too" do

      %{
        "National Org" => :facility,
        "Something Laboratory" => :facility,
        "eduID.ZZ" => :other,
        "Australian Federation" => :other,
        "Alan Turing Institute" => :facility,
        "American Chemical Society" => :nonprofit,
        "The Something Institution" => :nonprofit,
        "Foundation for International Education" => :nonprofit,
        "Development Agency" => :government,
        "Municipal Library Somewhere" => :library,
        "National Library of Spain" => :library,
        "Korea Institute of " => :education,
        "Centre for Agricultural Research" => :facility

      }
      |> Enum.each(
           fn {name, type} ->

             %Organization{
               type: rtype
             } = Tidy.assume_type(
               %Organization{
                 noid: "placeholder",
                 type: :unknown,
                 displaynames: %{
                   "en" => name
                 }
               }
             )

             assert type == rtype

           end
         )
    end

  end

  describe "swap_bad_names/1" do

    test "displaynames that are actually service names, or just too specific, are swapped with names" do
      [
        "Moodle Service",
        "University Moodle",
        "SP For Research",
        "Big University VLE ",
        "College IdP",
        "Test Service",
        " test test",
        "Service Provider Us",
        "SSO Service"
      ]
      |> Enum.each(
           fn service_name ->

             %Organization{
               displaynames: %{
                 "en" => rname
               },
             } = Tidy.swap_bad_names(
               %Organization{
                 noid: "placeholder",
                 displaynames: %{
                   "en" => service_name
                 },
                 names: %{
                   "en" => "Maybe a better name"
                 }
               }
             )

             assert "Maybe a better name" == rname

           end
         )
    end

  end

  describe "edit_bad_names/1" do

    test "displaynames that still contain service words have them removed" do

      %{
        "Moodle University" => "University",
        "University Moodle" => "University",
        "University VLE" => "University"
      }
      |> Enum.each(
           fn {old, new} ->

             %Organization{
               displaynames: %{
                 "en" => rname
               },
             } = Tidy.edit_bad_names(
               %Organization{
                 noid: "placeholder",
                 displaynames: %{
                   "en" => old
                 }
               }
             )

             assert new == rname

           end
         )
    end

  end

  describe "not_provided_by/1" do

    test "Displaynames that are 'provided by' should have that removed" do
      assert %Organization{
               displaynames: %{
                 "en" => "the Digital Curation Centre"
               }
             } = Tidy.not_provided_by(
               %Organization{
                 noid: "placeholder",
                 displaynames: %{
                   "en" => "DMPonline is a data management planning tool provided by the Digital Curation Centre"
                 }
               }
             )

      assert %Organization{
               displaynames: %{
                 "en" => "GARR"
               }
             } = Tidy.not_provided_by(
               %Organization{
                 noid: "placeholder",
                 displaynames: %{
                   "en" => "SP Demo provided by GARR"
                 }
               }
             )

      assert %Organization{
               displaynames: %{
                 "en" => "TI Sparkle"
               }
             } = Tidy.not_provided_by(
               %Organization{
                 noid: "placeholder",
                 displaynames: %{
                   "en" => "Federated Cloud services provided by TI Sparkle"
                 }
               }
             )

      assert %Organization{
               displaynames: %{
                 "en" => "University of Parma"
               }
             } = Tidy.not_provided_by(
               %Organization{
                 noid: "placeholder",
                 displaynames: %{
                   "en" => "Moodle Elly Didattica provided by University of Parma"
                 }
               }
             )

      assert %Organization{
               displaynames: %{
                 "en" => "Airbus"
               }
             } = Tidy.not_provided_by(
               %Organization{
                 noid: "placeholder",
                 displaynames: %{
                   "en" => "Jisc geospatial data service provided by Airbus"
                 }
               }
             )

      
      
      
      
    end

  end



end
