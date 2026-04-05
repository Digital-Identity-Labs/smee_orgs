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
                        "en" => name
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

    end

  end

  describe "edit_bad_names/1" do

    test "displaynames that still contain service words have them removed" do

    end

  end

  describe "not_provided_by/1" do

    test "Displaynames that are 'provided by' should have that removed" do

    end

  end



end
