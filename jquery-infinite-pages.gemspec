# -*- encoding: utf-8 -*-
require File.expand_path('../lib/jquery/infinite_pages/version', __FILE__)

Gem::Specification.new do |s|
  s.name           = "jquery-infinite-pages"
  s.version        = JqueryInfinitePages::VERSION
  s.licenses       = ["MIT"]
  s.summary        = "Infinite pages for jQuery + Rails"
  s.description    = "A light-weight infinite scrolling jQuery plugin, wrapped in a gem for Rails"
  s.authors        = ["Zach Millman"]
  s.email          = ["zach@magoosh.com"]
  s.homepage       = "https://github.com/magoosh/jquery-infinite-pages"
  s.files          = Dir["{lib,app}/**/*"] + ["LICENSE", "README.md"]
  
  s.add_dependency "jquery-rails"
  s.add_dependency "coffee-script"
  s.add_dependency "railties", ">= 3.1"
end
