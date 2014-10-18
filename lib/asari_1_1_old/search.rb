#
# Search
#
def self.active_asari_raw_search(domain, query, search_options = {})
  asari = Asari.new asari_domain_name(domain)
  fields = ACTIVE_ASARI_CONFIG[domain].map {|field| field.first.to_sym}
  fields = fields.concat([:active_asari_id])
  search_options[:return_fields] = fields
  asari.search query, search_options
end

def self.active_asari_search(domain, query, search_options = {})
  raw_result = active_asari_raw_search domain, query, search_options
  objectify_results raw_result
end

def self.objectify_results(hash_results)
  results = {}
  hash_results.each do |key, value|
    results[key] = Result.new.raw_result = value # = ResultObject.new
    #results[key].raw_result = value
  end
  results
end

# drops 'search-' from the front
def asari_endpoint
  self.search_endpoint[7..-1]
end