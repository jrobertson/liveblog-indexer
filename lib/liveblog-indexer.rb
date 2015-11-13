#!/usr/bin/env ruby

# file: liveblog-indexer.rb

require 'xws'
require 'json'
require 'rxfhelper'


class LiveBlogIndexer

  def initialize(filepath='wordindex.json', urls_indexed: 'urls-indexed.json')

    @wordindex_filepath, @urls_index_filepath = filepath, urls_indexed
    @master = if filepath and File.exists? filepath then
      JSON.parse(File.read(filepath))
    else
      {}
    end

    @xws = XWS.new
        
    @url_index = if urls_indexed and File.exists? urls_indexed then
      JSON.parse(File.read(urls_indexed))
    else
      {}
    end

  end

  def add_index(src)

    doc = if src.is_a? String then
      Rexle.new(RXFHelper.read(src).first )
    else
      src
    end
    
    link = doc.root.element('summary/link/text()')
    return unless link
    
    sections = doc.root.xpath 'records/section'

    sections.each do |section|

      url = "%s/#%s" % [link[/^https?:\/\/[^\/]+(.*)(?=\/$)/,1], \
                                                       section.attributes[:id]]
      h = @xws.scan section.element('details')
      
      h.each do |k, v|
        
        word, count = k, v

        keyword = @master[word]

        if keyword then

          keyword[url] = count
          
        else

          @master[word] = {}
          @master[word][url] = count

        end # /keyword
      end # /h
    end # /section
    
    true
  end # /add_index
  
  def crawl(location)
    
    index_file location
    save @wordindex_filepath
    File.write @urls_index_filepath, @url_index.to_json
    
  end  

  def save(filepath=nil)

    File.write filepath, @master.to_json
    puts 'saved ' + File.basename(filepath)

  end
  
  private
  
  def index_file(location)
    
    return if @url_index.has_key? location
    
    puts 'indexing : ' + location.inspect
    doc = Rexle.new(RXFHelper.read(location).first)
    summary = doc.root.element 'summary'
    return unless summary
    
    result = add_index doc
    return  unless result

    prev_day = summary.text 'prev_day'

    if prev_day then
      url = prev_day + 'formatted.xml'
      @url_index[url] = {last_indexed: Time.now}
      index_file(url) 
    end
  end


end