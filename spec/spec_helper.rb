$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'niceogiri'
require 'minitest/spec'

MiniTest::Unit.autorun
