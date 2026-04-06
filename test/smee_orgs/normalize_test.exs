defmodule NormalizeTest do
  use ExUnit.Case
  
  alias SmeeOrgs.Normalize
  
  
  describe "noid/1" do
    
    test "downcases noids" do
      assert "my_organization" = Normalize.noid("MY_ORGANIZATION")
    end

    test "trims whitespace" do
      assert "my_organization" = Normalize.noid("    MY ORGANIZATION   ")
    end
    
    test "builds noids from names" do
      assert "my_example_org" = Normalize.noid("My Example Org")
    end
    
    test "removes business suffixes" do
      assert "my_example_org" = Normalize.noid("My Example Org PLC")
      assert "my_example_org" = Normalize.noid("My Example Org Ltd")
      assert "my_example_org" = Normalize.noid("My Example Org Limited")
      assert "my_example_org" = Normalize.noid("My Example Org Plc")
      assert "my_example_org" = Normalize.noid("My Example Org Inc")
      assert "my_example_org" = Normalize.noid("My Example Org Incorporated")
      assert "my_example_org" = Normalize.noid("My Example Org Corporation")
      assert "my_example_org" = Normalize.noid("My Example Org Corporation")
      assert "my_example_org" = Normalize.noid("My Example Org Pte")
      assert "my_example_org" = Normalize.noid("My Example Org BV")
      assert "my_example_org" = Normalize.noid("My Example Org co")
      assert "my_example_org" = Normalize.noid("My Example Org corp")
      assert "my_example_org" = Normalize.noid("My Example Org oy")
      assert "my_example_org" = Normalize.noid("My Example Org LLC")
    end

    test "removes service suffixes" do
      assert "my_example_org" = Normalize.noid("My Example Org IdP")
      assert "my_example_org" = Normalize.noid("My Example Org SP")
      assert "my_example_org" = Normalize.noid("My Example Org VLE")
      assert "my_example_org" = Normalize.noid("My Example Org Moodle")
      assert "my_example_org" = Normalize.noid("My Example Org Test")
    end

#    test "removes internet domain suffixes" do
#      assert "my_example_org" = Normalize.noid("My Example Org.com")
#      assert "my_example_org" = Normalize.noid("My Example Org.org")
#      assert "my_example_org" = Normalize.noid("My Example Org.net")
#    end

    test "removes trailing the" do
      assert "my_example_org" = Normalize.noid("My Example Org, the")
      assert "my_example_org" = Normalize.noid("My Example Org The")
    end
    
    test "replaces spaces with underscores" do
      assert "my_example" = Normalize.noid("My Example")
    end

    test "removes most punctuation" do
      assert "anexample" = Normalize.noid("An-Example")
      assert "anexample" = Normalize.noid("An.Example")
      assert "anexample" = Normalize.noid("An'Example")
      assert "anexample" = Normalize.noid("An+Example")
    end

    test "but not all punctuation" do
      assert "an&example" = Normalize.noid("An&Example")
    end
    
    test "will override and replace certain known noid values and simple patterns" do
      assert "jisc" = Normalize.noid("Jisc Thing")
      assert "geant" = Normalize.noid("géantsomething")
    end
    
  end
  
  describe "lang_map/1" do
    
    test "returns an empty map if passed nil" do
      assert %{} == Normalize.lang_map(nil)
    end
    
    test "converts keys to strings" do
      assert %{"en" => "hello", "fr" => "bonjour"} = Normalize.lang_map(%{en: "hello", fr: "bonjour"})
    end

    test "missing/nil keys become en (or the default language)" do
      assert %{"fr" => "bonjour", "en" => "weird"} = Normalize.lang_map(%{"fr" => "bonjour", nil => "weird"})
      assert %{"fr" => "bonjour", "en" => "also weird"} = Normalize.lang_map(%{"fr" => "bonjour", "" => "also weird"})
    end
    
  end
  
  describe "lang_key/1" do

    test "converts key to strings" do
      assert "en" = Normalize.lang_key(:en)
    end

    test "missing/nil key becomes en (or the default language)" do
      assert "en" = Normalize.lang_key(nil)
      assert "en" = Normalize.lang_key("")
    end
    
  end
  
  describe "lang_value/1" do
    
    test "are converted to strings" do
      assert "bonjour" = Normalize.lang_value("bonjour")
      assert "bonjour" = Normalize.lang_value(:bonjour)
    end
    
    test "are trimmed" do
      assert "hello there" = Normalize.lang_value("  hello there    ")
    end
    
  end
  
  describe "url/1" do
    
    test "invalid URLs that should never have been published are replaced with nil" do
      assert is_nil Normalize.url("unspecified")
      assert is_nil Normalize.url("localhost")
      assert is_nil Normalize.url("GOSC")
      assert is_nil Normalize.url(":")
      assert is_nil Normalize.url("ohmygod.localhost")
      assert is_nil Normalize.url("localhost")
      assert is_nil Normalize.url("whywhy.internal")
    end
    
    test "domains/hostnames are converted to URL format" do
      assert "https://binary-ape.org" = Normalize.url("binary-ape.org")
    end

    test "none-HTTP URLs are replaced by nil. No LDAP or mail here, should it happen" do
      assert is_nil Normalize.url("ldap://myserver.example.com:389")
      assert is_nil Normalize.url("mailto:pete@mimoto.co.uk")
    end
    
  end
  
  describe "base_domain/1" do
    
    test "domains are trimmed back" do
      assert "example.org" = Normalize.base_domain("sp.something.example.org")
    end
    
    test "URLs are converted to domains and trimmed back" do
      assert "example.org" = Normalize.base_domain("https://sp.something.example.org")
    end
    
  end
  
  describe "type/1" do
    
    test "Types are converted to existing atoms" do
      assert :education = Normalize.type(:education)
      assert :education = Normalize.type("education")
    end

    test "Unknown types are logged and returned as :unknown" do
      assert :unknown = Normalize.type("womble")
    end
    
  end

  describe "types/0" do

    test "returns the list of acceptable types" do
      assert [:education, :healthcare, :company, :archive, :nonprofit, :government, :facility, :other, :unknown] = Normalize.types()
    end
    
  end
  
end
