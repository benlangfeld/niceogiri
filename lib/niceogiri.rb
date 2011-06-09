%w{
  nokogiri

  niceogiri/version
  niceogiri/core_ext/nokogiri
  niceogiri/xml/node
}.each { |f| require f}
