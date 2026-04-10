defmodule SmeeOrgs.MixProject do
  use Mix.Project

  def project do
    [
      app: :smee_orgs,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      description: "SAML metadata Organization extension for Smee",
      package: package(),
      name: "SmeeOrgs",
      source_url: "https://github.com/Digital-Identity-Labs/smee_orgs",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [
        tool: ExCoveralls
      ],
      cli: cli(),
      docs: [
        main: "readme",
        logo: "logo.png",
        extras: ["README.md", "LICENSE"]
      ],
      dialyzer: [
        plt_add_apps: [:mix, :smee, :smee_feds]
      ],
      deps: deps(),
      compilers: Mix.compilers() ++ [:rambo], # Needed until issue fixed in Rambo
      elixirc_paths: elixirc_paths(Mix.env)
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:smee, ">= 0.6.0"},
      {:ror, ">= 0.1.0"},
      {:sweet_xml, "~> 0.7"},
      {:jason, "~> 1.4"},
      {:domainatrex, "~> 3.2"},
      {:jsonpatch, "~> 2.3"},
      {:find_site_icon, "~> 0.5"},

      {:smee_feds, "~> 0.4.0", only: [:dev, :test], runtime: false},
      {:apex, "~> 1.2", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.14 and >= 0.14.4", only: [:dev, :test]},
      {:benchee, "~> 1.3", only: [:dev, :test]},
      {:ex_doc, "~> 0.40.0"},
      ## FIX THIS
      {:earmark, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:doctor, "~> 0.21", only: :dev, runtime: false},
      {:json_comparator, "~> 1.0", only: :test, runtime: false},
      {:table_rex, "~> 4.1", only: [:dev, :test]}
    ]
  end

  defp package() do
    [
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => "https://github.com/Digital-Identity-Labs/smee_orgs"
      }
    ]
  end

  def cli do
    [
      preferred_envs: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support", "priv"]
  defp elixirc_paths(_), do: ["lib", "priv"]

end
