defmodule TldToCcTest do
  use ExUnit.Case
  
  alias SmeeOrgs.TldToCc

  describe "domain_to_country/1" do
    
    test "returns the correct country code if input domain is in capitals or mixed case" do
      assert "BR" = TldToCc.domain_to_country("BR")
      assert "US" = TldToCc.domain_to_country("Edu")
    end
    
    test "returns USA top-level domains as US" do
      assert "US" = TldToCc.domain_to_country("edu")
      assert "US" = TldToCc.domain_to_country("gov")
      assert "US" = TldToCc.domain_to_country("mil")
      assert "US" = TldToCc.domain_to_country("arpa")
    end
    
    test "awkward countries like the UK have the correct, different country code" do
      assert "GB" = TldToCc.domain_to_country("uk")
    end

    test "normal countries probably have the same code" do
      assert "DE" = TldToCc.domain_to_country("de")
    end
    
    test "missing, empty, unknown and nil input results in the ZZ code" do
      assert "ZZ" = TldToCc.domain_to_country("")
      assert "ZZ" = TldToCc.domain_to_country(nil)
      assert "ZZ" = TldToCc.domain_to_country("X1")
    end
    
  end
  
end
