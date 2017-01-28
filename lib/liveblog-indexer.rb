#!/usr/bin/env ruby

# file: liveblog-indexer.rb

require 'xws'
require 'json'
require 'rxfhelper'


class LiveBlogIndexer

  def initialize(filepath: '.', word_index: 'wordindex.json', \
                                                   url_index: 'url_index.json')

    @filepath, @wordindex_filepath, @urls_index_filepath = filepath, \
                                                        word_index, url_index
    @master = if word_index and File.exists? File.join(filepath,word_index) then
      JSON.parse(File.read(File.join(filepath, word_index)))
    else
      {}
    end

    @xws = XWS.new
        
    @url_index = if url_index and \
                             File.exists? File.join(filepath, url_index) then
      JSON.parse(File.read(File.join(filepath, url_index)))
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
    File.write File.join(@filepath, @urls_index_filepath), @url_index.to_json
    
  end

  def inspect()
    "#<LiveBlogIndexer:#{self.object_id}>"
  end

  def save(filename='wordindex.json')

    File.write File.join(@filepath, filename), @master.to_json
    puts 'saved ' + filename

  end
  
  # search the word_index file with a keyword e.g. hdmi
  # results are sorted by exact match with a hashtag, exact keyword match, 
  # followed by words which contain the keyword e.g. micro-hdmi
  #
  # links for each result are sorted by date
  # 
  def search(keyword)

    def add_links(a)

      a.sort_by do |uri|

        string = uri[/^\/liveblog\/(\d{4}\/\w{3}\/\d+)/,1].gsub('/','')
        Date.strptime(string, "%Y%b%d")
        
      end.reverse

    end        
    
    h = @master
    grepped = h.keys.grep /#{keyword}/i
    # e.g. => ["hdmi=safe", "hdmi", "micro-hdmi", "#hdmi"]

    # sort results by importance
    r = []

    # hashtag should be first
    key = grepped.delete '#' + keyword
    r.concat add_links(h[key].keys) if key

    # the word on its own
    key = grepped.delete keyword
    r.concat add_links(h[key].keys) if key
    
    r.concat grepped.map {|x| add_links(h[x].keys)}
    
    return r.uniq
    
  end
  
  private
  
  def index_file(location)

    return if @url_index.has_key? location
    
    begin
      doc = Rexle.new(RXFHelper.read(location).first)
    rescue
      return
    end
    
    summary = doc.root.element 'summary'
    return unless summary
    
    result = add_index doc
    
    return  unless result
    @url_index[location] = {last_indexed: Time.now}    

    prev_day = summary.text 'prev_day'

    if prev_day then
      url = prev_day + 'formatted.xml'
      index_file(url)
    end
  end

end