# Introducing the liveblog-indexer gem

    require 'liveblog-indexer'

    lbi = LiveBlogIndexer.new
    lbi.add_index 'https://www.jamesrobertson.eu/liveblog/2015/nov/10/formatted.xml'
    lbi.save 'indexed.json'

This gem is under development, yet it can index a liveblog page. It does this by scanning each section for words to index, while ignoring specific HTML elements including *pre*, *code*, and *time*.

Note: JSON was used because it's much faster to work with than a Polyrex document, although it also saves in Polyrex format for future pruposes.

## Resources

* liveblog-indexer https://rubygems.org/gems/liveblog-indexer

liveblog indexer indexed

