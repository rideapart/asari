# Asari 1.1-Pre [![Build Status](https://travis-ci.org/lgleasain/asari.svg?branch=master)](https://travis-ci.org/lgleasain/asari)

Asari is a Ruby wrapper for AWS CloudSearch that supports both the 2011 and 2013 APIs. It offers easy
integration with vanilla Ruby models, ActiveRecord, and Rails.

* [Getting Started](#getting-started)
  * [Installation](#installation)
  * [Configuration](#configuration)
  * [Upgrading from 1.0](#upgrading-from-10)
* [Clients](#clients)
  * [Names and Prefixes](#names-and-prefixes)
  * [Creation and Deletion](#creation-and-deletion)
  * [Configuration](#configuration-2)
* [Domains](#domains)
  * [Names and Prefixes](#names-and-prefixes)
  * [Creation and Deletion](#creation-and-deletion)
  * [Configuration](#configuration-2)
* [Documents](#domains)
  * [Names and Prefixes](#names-and-prefixes)
  * [Creation and Deletion](#creation-and-deletion)
  * [Configuration](#configuration-2)
* [Using the Clients](#using-the-clients)
* [Model Integration](#model-integrations-1)
* [Roadmap](#roadmap)
* [Contributing](#contributing)
* [License](#license)

#### Why Asari?

"Asari" is Japanese for "rummaging search." Seemed appropriate.

## Getting started

### Installation

Asari 1.1 is developed on ruby 2.1.2 and has been tested on 1.9.x and JRuby.

Add Asari to your Gemfile with:

```ruby
gem 'asari'
```

The Rails integration ActiveAsari has been developed with Rails 4.1. It's untested with Rails 3, but should
work. The ActiveRecord extension is autoloaded whenever you include it.

The generators and rake tasks are automatically included in a standard Rails application. If you have a custom load
order, make sure you require `active_asari/railtie` before your railties are executed.

### Configuration

If you're using Rails, you can generate sample configuration files with `rails generate asari:install`. This will create
a sample configuration file at `config/initializers/asari.rb`, which you should read carefully and configure for yourself.

The basic configuration options for Asari are
```ruby
Asari::Domain.config.default_region = 'us-west-1'  # Any valid region, default 'us-east-1'
Asari::Domain.config.default_api_version = '2011'  # '2011' or '2013', default '2013'
```

Depending on the current environment of your application, you'll also want to set
```ruby
Asari.mode == :production # :sandbox or :production, default :sandbox'
```
**Note that `rails generate asari:install` will automatically include this line in `config/environments/production.rb`.**

This option tells Asari whether to actually perform requested actions on CloudSearch (:production), or to return mock
responses (:sandbox). There are no "local" versions of CloudSearch, and search instances can be expensive, so sandbox mode
is helpful when developing and testing. See the [Testing section](#testing) for info on how to configure the mocks.

### Upgrading from 1.0

#### Breaking changes

* The default API version is now '2013'. If you still need to use the 2011 API, make sure you set
  `Asari.config.client.api_version = '2011'`. Domain configuration is still unsupported with the 2011 API.
* The module to include into your searchable classes is still `ActiveAsari::ActiveRecord` if you're using ActiveRecord,
  but use `Asari::Searchable` (its parent) instead with vanilla ruby classes. `Asari::Searchable` replaces
  `Asari::ActiveRecord`, so remove any references to the latter.
* If you used ActiveAsari's `ACTIVE_ASARI_CONFIG` and `ACTIVE_ASARI_ENV` to hold your document schema and domain environment
  prefixes, you must now call `ActiveAsari.load_configuration_constants` to load them into configuration. The 1.0 method
  of configuration is deprecated. Please see the new syntax in the previous section. Loading IAM credentials from the
  ENV file was not done before, but is now possible using the new config syntax.
* In 1.0 Asari would run in production mode as long as `Asari.mode != :sandbox`. Now, Asari requires that
`Asari.mode == :production` before it will run.
* `Asari::MissingSearchDomainException` has been replaced with the more general `Asari::MissingDomainException`
* CLOUDSEARCH_API_VERSION and RACK_ENV/RAILS_ENV environment variables are now loaded into config at start and set.
  If you need to make changes to these settings during runtime, please use the config methods or simply reload config


#### Backwards compatible changes

##### Clients

Asari now has three clients:
 * `Asari::Client::HTTParty` (holding all the API functionality of the old `Asari`)
 * `Asari::Client::SDK`
 * `Asari::Client::SDK2`

So `Asari` is now a module, not a client class. For now, it will pretend to be a `Asari::Client::HTTParty`, so `Asari.new`
will still work. This is deprecated though, and instantiation should be done using a specific client.

##### Version

To set the default API version, use `Asari.config.client.api_version=` instead of `ENV['CLOUDSEARCH_API_VERSION']`.
The environment variable will still be picked up, but is deprecated. If you need to pass a different API version to your
applications using environment variables, simply set
`Asari.config.client.api_version = ENV['CLOUDSEARCH_API_VERSION']`.

Version strings are now stored in YYYY format instead of YYYY-MM-DD. Versions supplied to `ENV['CLOUDSEARCH_API_VERSION']`
in YYYY-MM-DD format will still work.

Client-level changes to the version are supported by the HTTParty client (and should be possible using SDK1 eventually).

##### Region

A default region can now be set with `Asari.config.client.default_region`, so you don't need to set a region on
individual client instances any more, i.e. instead of

```ruby
# Every time you need to use Asari
a = Asari.new
a.aws_region = 'us-west-1'

# Every associated model
asari_index("my-search-domain", [field1, field2], :aws_region => "us-west-1")
```
you can

```ruby
Asari.config.client.default_region = 'us_west_1'
# Every time you need to use Asari
a = Asari.new

# Every associated model
asari_index("my-search-domain", [field1, field2])
```

Client#aws_region has been simplified to Client#region. The old syntax is deprecated.

Client-level region changes are possible with all clients.

## Clients

Asari supports using either of the currently available CloudSearch APIs over HTTP, the AWS SDK, and
the AWS SDK V2. Depending on the communication method used, Asari can:

 1. Create, update, and delete search documents
 2. Perform simple and structured searches with ranking and pagination, geo search using included helper methods
 3. Create, delete, index, and set IP permissions on domains
 4. Avoid IP-based permissions and use HTTPS by automatically signing requests using EC2 Profiles and IAM roles

|          |     2013 API         |   2011 API         |
| :------: |:--------------------:|:------------------:|
| AWS-SDK2 |   1, 2, 3, 4, *      | unsupported by SDK |
| AWS-SDK  |        3, 4          |      3, 4          |
|   HTTP   |        1, 2          |      1, 2          |

\* Using the recently released (Oct 2014) AWS SDK V2 and the 2013 API, Asari has the necessary tools to eventually support
all of CloudSearch's functionality.

Please see the Roadmap section for planned features.

## Domains

An AWS CloudSearch domain "encapsulates the data you want to search, indexing options that control how you can search the data
and what information you can retrieve from your search domain, and the search instances that index your data and
process search requests." - [docs](http://docs.aws.amazon.com/cloudsearch/latest/developerguide/creating-managing-domains.html)

Asari manages the domains associated with Searchable and ActiveRecord models, so if only plan on using those you can
skim this section.

### Names and Prefixes

Domain names are the primary mode of identification for instances - these are the identifiers listed in the CloudSearch
console. They're between 3 to 28 characters: a-z, 0-9, or -. If you're using multiple apps on your AWS account, you
likely want an app-name prefix attached to your domains. Similarly, you may find environment prefixes useful. In example:

```
app1-prod-doc-name
app1-prod-another-doc
app1-test-doc-name
app2-prod-app2s-primary-doc
...etc...
```

Asari can manage these for you. If you create a domain with

```ruby
Asari::Domain.new('some-searchable-doc')
```

It will automatically assume you mean

```
prd-some-searchable-doc in production
tst-some-searchable-doc in test
dev-some-searchable-doc in development
```

Where you environment is based on your Rails or Rack environment. You can manually set the environment at any time with
`Asari.environment = 'environment-name'`. Note this is separate from `Asari.mode=`, which is explained in the [Config](#configuration)
section. You can set custom environment prefixes (and attach them to new environments) with

 ```ruby
 Asari::Domain::Name.config.env_prefixes = {
   'production' => 'pr0',
   'staging' => 'st4g'
 } #..etc..
 ```

If you'd like to add an app prefix, simply set

```ruby
Asari::Domain::Name.config.app_prefix = 'app1'
```

It will automatically assume you mean

```
app1-prd-some-searchable-doc in production
app1-tst-some-searchable-doc in test
app1-dev-some-searchable-doc in development
```

**You can disable automatic prefixing of domain names by supplying the `:skip_prefixes` option when creating domains or
domain names.**

#### A Note on Domain Name Length
In the above example, with both prefixes we've already hit the 28 character limit for domain name length. The lesson here is to keep
your prefixes short, disable the ones you don't need, and provide short document name stems. `'some-searchable-doc'` didn't
seem long at first, but was quickly crowded out.

You can shorten environment prefixes:

```ruby
Asari::Domain::Name.config.env_prefixes = {
  'production'  => 'p',
  'test'        => 't',
  'development' => 'd'
}
```

Or simple disable them if you only ever connect to CloudSearch in production:

```ruby
Asari::Domain::Name.config.env_prefixes = {}
```

Asari by default will raise an error if your names are too long, but it's an important point to keep in mind.

### Creation and Deletion

By default, a domain object created with `Asari::Domain.new('domain-name')` will reach out to



### Access Policies



### Availability, Scaling, Analysis Schemes, Suggestors, and Expressions



## Documents
Documents are the static object representations of your data stored and searched by CloudSearch. If you're including Asari's
model helpers in your models, these too will be managed for you and you can skim this section.



### Indexing

### Creation and Deletion

## Search



### Your Search Domain

Amazon Cloud Search will give you a Search Endpoint and Document Endpoint.  When specifying your search domain in Asari omit the search- for your search domain.
For example if your search endpoint is "search-beavis-er432w3er.us-east-1.cloudsearch.amazonaws.com" the search domain you use in Asari would be "beavis-er432w3er".
Your region is the second item.  In this example it would be "us-east-1".

### Basic Search

    asari = Asari.new("my-search-domain-asdfkljwe4") # CloudSearch search domain
    asari.add_item("1", { :name => "Tommy Morgan", :email => "tommy@wellbredgrapefruit.com"})
    asari.search("tommy") #=> ["1"] - a list of document IDs
    asari.search("tommy", :rank => "name") # Sort the search
    asari.search("tommy", :rank => ["name", :desc]) # Sort the search descending
    asari.search("tommy", :rank => "-name") # Another way to sort the search descending


### Boolean/Structured Compound Query Usage

    asari.search(filter: { and: { title: "donut", type: "cruller" }})
    asari.search("boston creme", filter: { and: { title: "donut", or: { type: "cruller|twist" }}}) # Full text search and nested boolean logic 2011-02-01 API only

For more information on how to use Cloudsearch boolean queries (2011-02-01), [see the
documentation.](http://docs.aws.amazon.com/cloudsearch/latest/developerguide/booleansearch.html)
For more information on how to use Cloudsearch structured compound queries (2013-01-01),
[see the documentation.](http://docs.aws.amazon.com/cloudsearch/latest/developerguide/searching-compound-queries.html)

### Retrieving Data From Index Fields

By default Asari only returns the document id's for any hits returned from a search.
If you have result_enabled a index field you can have asari resturn that field in the
result set without having to hit a database to get the results.  Simply pass the
:return_fields option with an array of fields

    results = asari.search "Beavis", :return_fields => ["name", "address"]

The result will look like this

    {"23" => {"name" => "Beavis", "address" => "One CNN Center,  Atlanta"},
    "54" => {"name" => "Beavis C", "address" => "Cornholio Way, USA"}}


### Geospatial Queries

#### Api Version 2013-01-01



#### Api Version 2011-02-01

While CloudSearch 2011 does not natively support location search, you can implement rudimentary location search by
representing latitude and longitude as integers in your search domain. Asari has a Geography module you can use to
simplify the conversion of latitude and longitude to cartesian coordinates as well as the generation of a coordinate
box to search within. Asari's Boolean Query syntax can then be used to search within the area. Note that because
Cloudsearch only supports 32-bit unsigned integers, it is only possible to store latitude and longitude to two place
values. This means very precise search isn't possible using Asari and Cloudsearch.

    coordinates = Asari::Geography.degrees_to_int(lat: 45.52, lng: 122.68)
      #=> { lat: 2506271416, lng: 111298648 }
    asari.add_item("1", { name: "Tommy Morgan", lat: coordinates[:lat], lng: coordinates[:lng] })
      #=> nil
    coordinate_box = Asari::Geography.coordinate_box(lat: 45.2, lng: 122.85, meters: 7500)
      #=> { lat: 2505521415..2507021417, lng: 111263231..111334065 }
    asari.search("tommy", filter: { and: coordinate_box }
      #=> ["1"] = a list of document IDs

For more information on how to use Cloudsearch for location search, [see the
documentation.](http://docs.aws.amazon.com/cloudsearch/latest/developerguide/geosearch.html)

#### With ActiveAsari

Searching is done via ActiveAsari.active_asari_search.  IE:

    ActiveAsari.active_asari_search 'HoneyBadger', 'name:beavis',  :query_type => :boolean

The query_type allows you to specify if you want to do a boolean or regular query.  All other options are passed directly to asari,  so see the asari gem for documentation on how to use it.  Results are automatically returned in a hash of objects indexed by the document_id.  The object contains a raw_result accessor along with accessors for all returned fields in the hash.  So...

    my_result = ActiveAsari.active_asari_search 'HoneyBadger', 'beavis'
    my_result['6'].name.should include 'beavis'

Search parameters are passed directly to Amazon Cloud Search.  See it's documentation for otpions,  syntax etc..

#### Pagination

Asari defaults to a page size of 10 (because that's CloudSearch's default), but
it allows you to specify pagination parameters with any search:

    asari.search("tommy", :page_size => 30, :page => 10)

The results you get back from Asari#search aren't actually Array objects,
either: they're Asari::Collection objects, which are (currently) API-compatible
with will\_paginate:

    results = asari.search("tommy", :page_size => 30, :page => 10)
    results.total_entries #=> 5000
    results.total_pages   #=> 167
    results.current_page  #=> 10
    results.offset        #=> 300
    results.page_size     #=> 30



## Models

Asari provides various modules that help connect Ruby models to search domains to simplify synchronizing and searching.
ActiveRecord and Rails Integrations Asari comes bundled with ActiveAsari, which includes ActiveRecord update/delete
hook integration, rake tasks for managing domains, and generators for creating sample configuration.

### Base

    ## Model Integrations

    Any model can be associated with a ActiveAsari Object.
    This is done by adding the following three lines to the beginning of your model class.

        include Asari::Searchable
        or

        include Asari::ActiveRecord

        active_asari_index 'YourDomain'
              asari_index("search-domain-for-users", [:name, :email, :twitter_handle, :favorite_sweater])


      All active_asari fields are result enabled to allow you to retrive the result values from Amazon Cloud search.
      The index_field_type specifies the Amazon Cloud Search unit type.
      search_enabled specifies your ability to search on a field.
        text fields are always searchable,
        uint are configurable but default to searchable
        literals need to be enabled if you want to be able to search them.


    the second argument to asari\_index is the list of fields to maintain in the
    index, and can represent any function on your AR object. You can then interact
    with your AR objects as follows:

        # Klass.asari_find returns a list of model objects in an
        # Asari::Collection...
        User.asari_find("tommy") #=> [<User:...>, <User:...>, <User:...>]
        User.asari_find("tommy", :rank => "name")

        # or with a specific instance, if you need to manually do some index
        # management...
        @user.asari_add_to_index
        @user.asari_update_in_index
        @user.asari_remove_from_index

    You can also specify a :when option, like so:

        asari_index("search-domain-for-users", [:name, :email, :twitter_handle,
        :favorite_sweater], :when => :indexable)

    or

        asari_index("search-domain-for-users", [:name, :email, :twitter_handle,
        :favorite_sweater], :when => Proc.new { |user| !user.admin && user.indexable })

    This provides a way to mark records that shouldn't be in the index. The :when
    option can be either a symbol - indicating a method on the object - or a Proc
    that accepts the object as its first parameter. If the method/Proc returns true
    when the object is created, the object is indexed - otherwise it is left out of
    the index. If the method/Proc returns true when the object is updated, the
    object is indexed - otherwise it is deleted from the index (if it has already
    been added). This lets you be sure that you never have inappropriate data in
    your search index.

    ## Delayed Indexing,  Errors, FAQ

    Because index updates are done as part of the AR lifecycle by default, you also
    might want to have control over how Asari handles index update errors - it's
    kind of problematic, if, say, users can't sign up on your site because
    CloudSearch isn't available at the moment. By default Asari just raises these
    exceptions when they occur, but you can define a special handler if you want
    using the asari\_on\_error method:

        class User < ActiveRecord::Base
          include Asari::ActiveRecord

          asari_index(... )

          def self.asari_on_error(exception)
            Airbrake.notify(...)
            true
          end
        end

    In the above example we decide that, instead of raising exceptions every time,
    we're going to log exception data to Airbrake so that we can review it later and
    then return true so that the AR lifecycle continues normally.


### ActiveRecord


## Rails

### Generators

### Migrations

The ActiveAsari::Migrations class has methods to 'migrate' your cloud search instance to have domains
 with indexes specified in your config file.  We have a todo to add rake tasks to the gem.
 In the meantime you can all migrate_all to create everything in your configuration file or migrate_domain to
 migrate one domain.

This will automatically set up before\_destroy, after\_create, and after\_update
hooks for your AR model to keep the data in sync with your CloudSearch index -

Once you have this in your model, and have run your migrations all update,
create and deletes to the model in a non_test environment will automatically be performed in AmazonCloud search
keeping the two environments in sync.



      include Asari::ActiveRecord


While having asari auto index,  delete and update records can be handy,  it doesn't provide a great failover
mechanism if you are having communication issues between your system and cloud search.  To enable delayed indexing
add the following before requiring 'asari/active_record'.

    class Asari
      module ActiveRecord
        DELAYED_ASARI_INDEX = true
      end
    end

You can then manually trigger deletes,  adds and updates by calling asari_remove_from_index,
asari_add_to_index and asari_update_in_index on your model.

We also have support for batching updates by calling asari_add_items on a asari model object.

    user1 = User.create
    user2 = User.create
    User.asari_add_items [user1, user2, user3]

A batch delete_items can be accomplished via asari_remove_item on a asari model object

    User.asari_remove_items [1, 2, 8]




## Roadmap

With the AWS-SDK V2 [github](https://github.com/aws/aws-sdk-core-ruby),[docs](http://docs.aws.amazon.com/sdkforruby/api/frames.html)
released in October 2014, in theory we should be able to do all of the following relatively easily:

* perform every search CloudSearch supports, including faceting and native Geo support
* retrieve suggestions
* configure domain scaling, availability, and resource/role-based permissions
* configure domain text analysis schemes (stemming, stopwords, synonyms, and language)
* configure domain expressions used for ranking and as results

It might also be helpful to build in support for using the SDK1 over the 2011 API, for those stuck on Ruby 1.9.3.

Pull requests are always welcome to get these features out.


## Contributing

If Asari interests you and you think you might want to contribute, hit us up on Github. You can also just fork it and
make some changes, but there's a better chance that your work won't be duplicated or rendered obsolete if you check in
on the current development status first.

Gem requirements/etc. should be handled by Bundler.

We have maintained close to 100% test coverage on the project. Your pull request will have a much better chance of being
accepted if you write specs for it.

### Contributors

* [Lance Gleason](https://github.com/lgleasain "lgleasain on GitHub")
* [Emil Soman](https://github.com/emilsoman "emilsoman on GitHub")
* [Chris Vincent](https://github.com/cvincent "cvincent on GitHub")
* [Kyle Meyer](https://github.com/kaiuhl "kaiuhl on GitHub")
* [Brentan Alexander](https://github.com/brentan "brentan on GitHub")
* [Playon Sports](http://company.playonsports.com/)
* [Treehouse](http://teamtreehouse.com/)
* [Zach Risher](https://github.com/zrisher "zrisher on GitHub")

## License

MIT License, see [License.md](https://github.com/david-l-young/asari/blob/master/LICENSE.md).
Copyright 2012-2014 Tommy Morgan