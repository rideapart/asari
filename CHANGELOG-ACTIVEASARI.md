## ActiveAsari Changelog

#### Pending Implementation

#### Pending Release
* deprecations
  * ActiveAsari.active_asari_search is now accomplished through...... @todo
  * Configuring AWS credentials using AWS is deprecated if using Aws new sdk ....  @todo

* enhancements
  * Added this CHANGELOG

* refactorings
  * Abstracted the Document and Domain functionality that doesn't require rails out of ActiveAsari and into Asari
  * Abstracted Client methods and configuration out of ActiveAsari and into Asari

### 1.1.0 - October 20, 2014

### 1.0.1 - June 15, 2014
* defect fixes
  * Indexing bug

### 1.0.0 - June 9, 2014
* deprecations
  * Domain management using 2011 API

* enhancements
  * Uses 2013 API for Domain management

### 0.2.0 - April 27, 2014
* enhancements
  * Added Hasher for Redis integration

### 0.1.0 - April 16, 2014
* refactorings
  * Merged into Asari gem

### 0.0.2 - Oct 12, 2013
* features
  * ActiveRecord hook and id integration for Asari-enabled models
  * Domain names, endpoints, and field configs stored for simpler queries
  * Domain configuration through AWS-SDK client - creation, deletion, indexing, access policies
  * Objectification of search results


... lots of commits not documented in this log ...


### 0.0.1 - Jul 10, 2012
Initial commit