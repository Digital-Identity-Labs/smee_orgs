defmodule ClientTest do
  use ExUnit.Case

  alias SmeeOrgs.Client

  describe "get!/2" do

    test "fetches the body of HTTP get request, if request works" do
      assert "<!doctype html>\n<html" <> _ = Client.get!("https://digitalidentity.ltd.uk")
    end

    test "raises an exception if request doesn't work" do
      assert_raise(
        Req.TransportError,
        fn ->
          Client.get!("https://digitalidentity.ltd.ukxxx")
        end
      )
    end

  end

  describe "http/1" do

    test "returns a Req config struct with default HTTP options if no options are passed" do
      assert right: %Req.Request{
        options: %{
          cache: true,
          user_agent: "SmeeOrgs " <> _,
          cache_dir: _,
          http_errors: :raise,
          max_redirects: 3,
          max_retries: 3
        }
      } = Client.http()
    end

  end

  describe "http_agent_name/0" do

    test "agent string begins with SmeeOrg " do
      assert String.starts_with?(Client.http_agent_name(), "SmeeOrgs ")
    end

  end

end
