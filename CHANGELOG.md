# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2026-06-23
Patch release

### Possible breaking changes
* The new FindSiteIcon package may cause the low open file limit on Macs to be exceeded. Use `ulimit -n 65536` to
  work around this

### Improvements
* FindSiteIcon updated to v1.0.2, which uses Req and has other optimizations. Favicons may now be used if nothing
  better is found.
* Two example scripts have been included in the repo. They can be used to demonstrate and test logo detection.

### Other Changes
* Some tests have been temporarily disabled or changed to account for CERN search results from ROR changing

## [0.1.0] - 2026-04-11
Initial release

[0.1.1]: https://github.com/Digital-Identity-Labs/smee_orgs/compare/releases/tag/0.1.0...0.1.1
[0.1.0]: https://github.com/Digital-Identity-Labs/smee_orgs/compare/releases/tag/0.1.0
