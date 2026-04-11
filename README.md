# SmeeOrgs
<img src="https://raw.githubusercontent.com/Digital-Identity-Labs/smee/a897646d54d5c6c7ef852b11a0e5d64611147580/logo.png" width="128px" alt="Smee Logo" style="float: right; margin: 6px;">

`SmeeOrgs` is an extension to [Smee](https://github.com/Digital-Identity-Labs/smee) dedicated to extracting and processing
the Organization information inside SAML entity metadata. Rather niche but possibly useful.

Organisation data is not a load-bearing aspect of SAML metadata - it's not used during authentication, and nothing breaks
if it's incorrect. It can also be difficult for federations to manage and maintain. SmeeOrgs offers features that hopefully
fix and improve this organisation data and make it more useful.

[![Hex pm](http://img.shields.io/hexpm/v/smee_orgs.svg?style=flat)](https://hex.pm/packages/smee_orgs)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](http://hexdocs.pm/smee_orgs/)
![Github Elixir CI](https://github.com/Digital-Identity-Labs/smee_orgs/workflows/Elixir%20CI/badge.svg)

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2FDigital-Identity-Labs%2Fsmee_orgs%2Fmain%2Fsmee_orgs_notebook.livemd)

## Features

* Extract organization data from Smee entity structs and metadata, as lists or streams.
* Assign simple identifers to organizations
* Easily filter lists of organisations by type, tags, and other criteria.
* Merge, deduplicate and aggregate duplicated records
* Enhance organisation records with [ROR](https://ror.org) data
* Patch organisation data to hopefully fix and improve it
* Find and add logos automatically
* Export Organization data as JSON

The top level `SmeeOrgs` module has functions for extracting and processing lists of organisations from Metadata.
Two other modules may be of use:

* `SmeeOrgs.Filter` - simple filtering functions for selecting Organisations by various criteria
* `SmeeOrgs.Organization` - a struct for organisation data and functions for easily accessing the data

## Problems and Possible Solutions 

* **Identifiers**: There is no single strong identifer in the metadata fragment for Organisation data - names and URLs are localized 
* **Duplication**: Organization data is included with each Entity so it's naturally duplicated if an Organization has more 
  than one IdP or SP. If you want to assemble more structured and normalized data, maybe mapping services to 
  service-providing organisations, then you need to deduplicate it.
* **Inconsistency**: Organization data is normally added to federations piecemeal - the same organization may be described 
  with different details. Federations may describe the same organisation with different details, and organisations may
  not provide consistent descriptions of themselves.
* **Stale data**: Organizations change over time, they rename or merge, change their websites and update branding. There's
  no need to contact federations to update organization details (nothing will break) so the data drifts away from reality.
* **Legacy workarounds**: Before MDUI data could be included in metadata it was common to use Organisation data to describe
  the service, not the organization. Many of these remain in metadata today.

Organisation information in SAML metadata isn't very important - nothing breaks if it contains errors, but because of this
errors can gradually acrue over time until making any use of it all may be difficult.

SmeeOrgs was created to (hopefully) build usable lists of organizations and their services. It attempts to make the raw 
information in SAML metadata more useful by doing the following:

* Assign identifiers to each record: an ID derived from a name, and a base domain.
* Attempt to fix identifiers so that records that have very different names get the same ID
* Deduplicate and merge records so that records that *appear* to be the same organization are combined 
* Apply patches to data to fix and improve records
* Lookup organizations using the ROR API to add additional information
* Find suitable logos/icons

At present a lot of the approaches listed above are a little too much like gaffer-tape. They appear to work remarkably well but 
errors will remain and you may find it necessary to add your own fixes. SmeeOrgs' patch functions can be used to do this but
it should be pretty easy to process the data in other ways too. The patch data included in SmeeOrgs is a demo and a starting-point: 
you should probably put together your own patch data for production use, or at least review the default patch data.

Please see the contributing section below if you have suggestions or fixes you wish to share.

## Examples

### Extracting an Organization struct from an Entity struct 
A single `Smee.Entity` struct can be parsed into a single `SmeeOrgs.Organization` struct using `SmeeOrgs.extract/1`

```elixir
  Smee.MDQ.source("http://mdq.ukfederation.org.uk/")
  |> Smee.MDQ.lookup!("https://cern.ch/login")
  |> SmeeOrgs.extract()
#=> %SmeeOrgs.Organization{
#     noid: "cernch",
#     base_domain: "cern.ch",
#     names: %{"en" => "cern.ch"},
#     displaynames: %{"en" => "CERN"},
#     urls: %{"en" => "http://www.cern.ch/"},
#     ror: nil,
#     logo_url: nil,
#     location: nil,
#     wikipedia: nil,
#     country: "CH",
#     entity_uris: ["https://cern.ch/login"],
#     domains: ["www.cern.ch"],
#     tags: [],
#     type: :unknown,
#     registrars: ["http://rr.aai.switch.ch/"],
#     federations: ["http://rr.aai.switch.ch/", "https://cern.ch/login"]
#  }

```

### Parsing all organizations in a federation into a list
`SmeeOrgs.list/2` and `SmeeOrgs.stream/2` will accept a `Smee.Metadata` struct and process all entities into Organization
structs.

```elixir
Smee.source("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")
|> Smee.fetch!()
|> SmeeOrgs.list()
```

### Filtering: only parsing organization data for SPs into a list, then selecting Japanese organizations
If you want to select which entities to extract Organizations from, filter an entity stream before passing it to SmeeOrgs. 
SmeeOrgs also has its own filter module that can be used to select Organization structs.

```elixir
Smee.source("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")
|> Smee.fetch!()
|> Smee.Metadata.stream_entities()
|> Smee.Filter.sp()
|> SmeeOrgs.list()
|> SmeeOrgs.Filter.country("jp")
```

### Applying all processing functions to organizations in a federation, then dumping to a JSON file 
After creating Organization structs you can pass them to various functions for processing and hopefully improving the
data. 

```elixir
Smee.source("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")
|> Smee.fetch!()
|> SmeeOrgs.list()
|> SmeeOrgs.aggregate()
|> SmeeOrgs.enhance()
|> SmeeOrgs.patch!()
|> SmeeOrgs.add_logos()
|> SmeeOrgs.dump("organizations.json")

```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `smee_orgs` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:smee_orgs, "~> 0.1.0"}
  ]
end
```

SmeeOrgs requires [Smee](https://github.com/Digital-Identity-Labs/smee), which has its own unusual requirements, so
please make sure you read the documentation for installing Smee before using SmeeOrgs.


## Alternatives and Sources

I normally list other projects that provide similar functionality but in this case I can't think of any. Please tell me
if you know of similar projects and I will include them here.


## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/smee_orgs>.

## Contributing

There are going to be problems in the original data but also mistakes in SmeeOrgs' attempts to improve the 
original data. If you spot an error please raise an issue or pull request with a correction to the ID fixes or patches
in SmeeOrgs, but also consider contacting the organisation or publishing federation first if the problem can be resolved
in the federation's metadata.

You can request new features by creating an [issue](https://github.com/Digital-Identity-Labs/smee_orgs/issues),
or submit a [pull request](https://github.com/Digital-Identity-Labs/smee_orgs/pulls) with your contribution.

If you are comfortable working with Python but Smee's Elixir code is unfamiliar then this blog post may help:
[Elixir For Humans Who Know Python](https://hibox.live/elixir-for-humans-who-know-python)

Please do not submit any PRs or issues generated by "AI". This is a slop-free project and all mistakes are carefully 
hand-crafted by humans.

## Copyright and License

Copyright (c) 2025, 2026 Digital Identity Ltd, UK

SmeeOrgs is Apache 2.0 licensed.

## Disclaimers
SmeeOrgs is not endorsed by The Shibboleth Foundation or any of the organizations mentioned within the code or data.
Digital Identity Ltd is not responsible for any changes you make to organization data using SmeeOrgs, and recommends that
you build your own patch data for production use.
The API may change considerably in the first few releases after 0.1.0.
Generated IDs may change between releases of SmeeOrgs before stabilizing.
