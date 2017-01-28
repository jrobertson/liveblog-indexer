Gem::Specification.new do |s|
  s.name = 'liveblog-indexer'
  s.version = '0.2.6'
  s.summary = 'This gem is under development. Generates a Liveblog indexed file in JSON format as well as Polyrex format.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/liveblog-indexer.rb']
  s.add_runtime_dependency('xws', '~> 0.1', '>=0.1.1')
  s.add_runtime_dependency('rxfhelper', '~> 0.2', '>=0.2.3')
  s.signing_key = '../privatekeys/liveblog-indexer.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/liveblog-indexer'
end
