## Asari Changelog

#### Pending Implementation
* I think having Asari and ActiveAsari in two separate gems makes a lot more sense, especially now that ActiveAsari
includes many Rails integrations besides ActiveRecord and all its CloudSearch interfaces have been moved into Asari.
They have very different purposes, dependencies, and functionality.

I could split this pull request between the two repos wellbredgrapefruit/asari and playon/activeasari rather easily,
but since you have gone through the trouble of combining them already, and I'm not sure if you'd prefer to have the two
gems live in the same repo (given traffic and maintenance considerations). Structuring a repo that holds multiple gems is a little beyond my current capacity. However,
I've maintained their separation in the CHANGELOGs and READMEs in anticipation of a split.

#### Pending Release
* enhancements
  * Config - Enabled loading IAM user access id and key from YAML config file for the SDK1 and SDK2
  * Clients -
  * Tests - Cleaned up dependency on not being included except in production


  * CHANGELOG - Added it
  * README - Added an overview section that discusses the various clients, APIs, and model integrations
  * README - Consolidated installation and configuration sections, updated to match new config process

  * AWS SDK V2 as an interface with the CloudSearch 2013 api    @todo
  * Native geospacial search support via AWS SDK               @todo
  * Domain management search support via AWS SDK             @todo

* refactorings
  * Abstracted the Document and Domain functionality that doesn't require rails out of ActiveAsari and into Asari
  * Abstracted Client methods and configuration out of ActiveAsari and into Asari
  * Consolidated Domain functionality into a class
  * Reorganized Client functionality into a base class with 3 extensions - HTTParty, SDK1, and SDK2

### 1.1.0 - October 20, 2014


... lots of commits not documented in this log ...


### 1.0.0 - April 16, 2014
* refactorings
  * Merged in ActiveAsari gem


... lots of commits not documented in this log ...


### 0.0.1 - Jul 10, 2012
Initial commit