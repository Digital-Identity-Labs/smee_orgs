defmodule UtilsTest do
  use ExUnit.Case

  alias SmeeOrgs.Utils

  describe "select_lang/2" do

    test "returns the string for the specified language if it exists" do
      assert "bonjour" = Utils.select_lang(%{"en" => "hello", "fr" => "bonjour"}, "fr")
    end

    test "when the preferred language string is unavailable, returns the string for the system default language if it exists" do
      assert "hello" = Utils.select_lang(%{"en" => "hello", "fr" => "bonjour"}, "jp")
    end

    test "when the preferred language and system default string are unavailable, returns... something, if it can" do
      assert "bonjour" = Utils.select_lang(%{"jp" => "こんにちは", "fr" => "bonjour"}, "en")
    end

    test "will return nil if the map is empty" do
      assert is_nil(Utils.select_lang(%{}, "br"))
    end


  end

  describe "select_lang_pref/2" do

    test "returns the string for the specified language if it exists" do
      assert "bonjour" = Utils.select_lang_pref(%{"en" => "hello", "fr" => "bonjour"}, "fr")
    end

    test "returns nil if the specified language does not exist" do
      assert is_nil Utils.select_lang_pref(%{"en" => "hello", "fr" => "bonjour"}, "jp")
    end

  end

  describe "select_lang_default/2" do

    test "returns the string for the system default if it exists (defaults to en)" do
      assert "hello" = Utils.select_lang_pref(%{"en" => "hello", "fr" => "bonjour"})
    end

    #test "language default can be set in the config TODO"

    test "returns nil if the system default language does not exist" do
      assert is_nil Utils.select_lang_pref(%{"jp" => "こんにちは", "fr" => "bonjour"})
    end

  end

  describe "select_lang_fallback/1" do

    test "returns the first available string sorted by language key (this tends to favour ASCII)" do
      assert "bonjour" = Utils.select_lang_fallback(%{"jp" => "こんにちは", "fr" => "bonjour"})
    end

    test "returns the only available string if only one is available" do
      assert "こんにちは" = Utils.select_lang_fallback(%{"jp" => "こんにちは"})
    end

    test "returns nil if nothing is there at all" do
      assert is_nil Utils.select_lang_fallback(%{})
    end

  end

  describe "extract_domain/1" do

    test "returns nil if passed nil" do
      assert is_nil Utils.extract_domain(nil)
    end

    test "can't handle invalid domains, will return nil" do
      assert is_nil Utils.extract_domain("")
      assert is_nil Utils.extract_domain(":")
      assert is_nil Utils.extract_domain("GOSC")
      assert is_nil Utils.extract_domain("unspecified")
    end

    test "will extract the hostname from a valid http(s) URL" do
      assert "indiid.net" = Utils.extract_domain("https://indiid.net/path")
      assert "example.com" = Utils.extract_domain("http://example.com/path")
    end

    test "will return nil from any other type of URL" do
      assert is_nil Utils.extract_domain("ldap://my.ldap.server.com")
    end

  end

  describe "extract_domains/1" do

    test "will return an empty list if passed nil" do
      assert [] = Utils.extract_domains(nil)
    end

    test "will extract domains from a list of valid URLs" do
      assert ["indiid.net", "example.com"] = Utils.extract_domains(
               ["https://indiid.net/path", "http://example.com/path"]
             )
    end

    test "will extract domains from a map where the values are valid URLs" do
      assert ["indiid.net", "example.com"] = Utils.extract_domains(
               %{"1" => "https://indiid.net/path", "2" => "http://example.com/path"}
             )
    end

    test "irrecoverably invalid or useless urls will not be returned" do
      assert ["indiid.net", "example.com"] = Utils.extract_domains(
               [
                 "https://indiid.net/path",
                 "http://example.com/path",
                 ":",
                 "GOSC",
                 "DEV.ITClientPortal.internal",
                 "localhost",
                 "http://mysite.localhost:8080"
               ]
             )
    end

    test "invalid urls that can be fixed will be fixed and returned as domains" do
      assert [
               "indiid.net",
               "example.com",
               "npmk.cz",
               "maren.ac.mw",
               "www.heal-link.gr",
               "www.nature.com",
               "www.hogent.be"
             ] = Utils.extract_domains(
               [
                 "https://indiid.net/path",
                 "http://example.com/path",
                 "npmk.cz",
                 " https://maren.ac.mw ",
                 "\n                http://www.heal-link.gr/\n            ",
                 "www.nature.com",
                 "\n\t    http://www.hogent.be\n\t    "
               ]
             )
    end

  end

  describe "set_if_empty/2" do

    test "will return the new value if the old value is nil" do
      assert "panda" = Utils.set_if_empty(nil, "panda")
    end

    test "will return the new value if the old value is an empty string" do
      assert "panda" = Utils.set_if_empty("", "panda")
    end

    test "will return the new value if the old value is ZZ" do
      assert "panda" = Utils.set_if_empty("ZZ", "panda")
    end

    test "will return the new value if the old value is :unknown" do
      assert "panda" = Utils.set_if_empty(:unknown, "panda")
    end

    test "otherwise returns the existing value" do
      assert "bamboo" = Utils.set_if_empty("bamboo", "panda")
    end

  end

  describe "add_to_unique_list/2" do

    test "will add a value to a list if it is not already present" do
      assert ["a", "b", "c"] = Utils.add_to_unique_list(["a", "b"], "c")
    end

    test "will not add a value to a list if it is already present" do
      assert ["a", "b"] = Utils.add_to_unique_list(["a", "b"], "b")
    end

    test "will not add nil to a list" do
      assert ["a", "b"] = Utils.add_to_unique_list(["a", "b"], nil)
    end

    test "the list will be sorted" do
      assert ["a", "b", "c", "d"] = Utils.add_to_unique_list(["b", "a", "c"], "d")
    end

  end

  describe "merge_lang_maps/2" do

    test "will combine two language maps" do
      assert %{"de" => "german", "en" => "english", "fr" => "french"} = Utils.merge_lang_maps(
               %{"en" => "english", "fr" => "french"},
               %{"de" => "german"}
             )
    end

    test "the *first* map has priority if keys clash" do
      assert %{"en" => "english1", "fr" => "french"} = Utils.merge_lang_maps(
               %{"en" => "english1", "fr" => "french"},
               %{"en" => "english2"}
             )
    end

  end

  describe "domain_to_country/1" do

    test "returns the correct country code if input domain is in capitals or mixed case" do
      assert "BR" = Utils.domain_to_country("BR")
      assert "US" = Utils.domain_to_country("Edu")
    end

    test "returns USA top-level domains as US" do
      assert "US" = Utils.domain_to_country("edu")
      assert "US" = Utils.domain_to_country("gov")
      assert "US" = Utils.domain_to_country("mil")
      assert "US" = Utils.domain_to_country("arpa")
    end

    test "awkward countries like the UK have the correct, different country code" do
      assert "GB" = Utils.domain_to_country("uk")
    end

    test "normal countries probably have the same code" do
      assert "DE" = Utils.domain_to_country("de")
    end

    test "missing, empty, unknown and nil input results in the ZZ code" do
      assert "ZZ" = Utils.domain_to_country("")
      assert "ZZ" = Utils.domain_to_country(nil)
      assert "ZZ" = Utils.domain_to_country("X1")
    end

  end


end
