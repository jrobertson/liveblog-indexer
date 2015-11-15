# Introducing the liveblog-indexer gem

    require 'liveblog-indexer'

    lbi = LiveBlogIndexer.new filepath: '/tmp', \
                    word_index: 'words_indexed.json', url_index: 'indexed.json'
    lbi.crawl 'https://www.jamesrobertson.eu/liveblog/2015/nov/13/formatted.xml'


This gem can not only index a single liveblog page it can crawl over all Liveblog pages. It does this by reading each formatted.xml which contains a link to the previous page. Within a page, it scans each section for words to index, while ignoring specific HTML elements including *pre*, *code*, and *time*.

Note: There are 2 files which are saved in JSON format, those are *words_indexed.json* and *urls_indexed.json*. The filepath and the filenames can be set at initialize().

## Resources

* liveblog-indexer https://rubygems.org/gems/liveblog-indexer

liveblog indexer indexed search
