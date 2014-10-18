=begin
    #attr_reader :excluded_ad_categories,
    before_filter :initialize_manager


    results = cloud_searcher.search(find, :page_size => per, :page => page)

    #results.total_entries #=> 5000
    #results.total_pages   #=> 167
    #results.current_page  #=> 10
    #results.offset        #=> 300
    #results.page_size     #=> 30

    highlight_field = 'text_content'
    highlights_max = 3 # 1 - 5, default 1
    highl
    highlight_querypart = "&highlight.#{highlight_field}="+
      "{max_phrases:#{highlights_max}, pre_tag:'<strong>', post_tag:'</strong>'}"

    ActiveAsari.active_asari_search 'HoneyBadger', 'beavis'
    myresult['6'].name.should include 'beavis'

    # controller
    params = {}

    find = params[:find] || nil
    page = params[:page] || 1
    per = 14

    # Init highlights with a specific hash
    #highlight_fields = {
    #  title:        {max: 3, start_tag: '<span class="found-keyword">', end_tag: '</span>'},
    #  category:     {max: 3, start_tag: '<span class="found-keyword">', end_tag: '</span>'},
    #  text_content: {max: 3, start_tag: '<span class="found-keyword">', end_tag: '</span>'},
    #}
    #highlight_fields.inject(''){|string, field|
    #  max =
    #}

    # Init highlights with array
    # Could configure defaults to below through module config
    highlight_fields = %w(title category body_text)

    highlight_options = {max_phrases: 3, pre_tag: '<span class="found-keyword">', post_tag: '</span>'}

    highlight_querypart = highlight_fields.inject(''){ |memo, field|
      memo << "&highlight.#{field}=#{highlight_options.to_json}"
    }

    text_to_find = 'keyword'

    query = text_to_find.present? ?
      text_to_find + highlight_querypart :
      ''

    results = cloud_searcher.search(query,
                                    :page_size => per,
                                    :page => page,
                                    :return_fields => ["title", "category", "body_text"]
    )

    p "\n\n", 'Asari results:', results.inspect

    # concern
    domain = AWS_CLOUD_SEARCH_ENDPOINTS[:rideapart_prod][:domain]
    region = AWS_CLOUD_SEARCH_ENDPOINTS[:rideapart_prod][:region]
    cloud_searcher = Asari.new(domain)
    cloud_searcher.aws_region = region

=end
end



=begin
  def initialize_manager
    domain = AWS_CLOUD_SEARCH_ENDPOINTS[:rideapart_prod][:domain]
    region = AWS_CLOUD_SEARCH_ENDPOINTS[:rideapart_prod][:region]
    cloud_searcher = Asari.new(domain)
    cloud_searcher.aws_region = region
  end
=end