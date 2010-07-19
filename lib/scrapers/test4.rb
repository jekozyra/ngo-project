#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'

@agent= WWW::Mechanize.new
@page = @agent.get('http://www.ngosinfo.gov.pk/SearchResults.aspx?name=&foa=0')

puts @agent.click @page.link_with(:text => 'Next')

