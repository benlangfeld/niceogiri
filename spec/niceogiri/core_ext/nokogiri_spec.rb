require 'spec_helper'

describe Nokogiri::XML::Node do
  let(:doc) { Nokogiri::XML::Document.new }

  it 'aliases #name to #element_name' do
    node = Nokogiri::XML::Node.new 'foo', doc
    node.should respond_to :element_name
    node.element_name.should == node.name
  end

  it 'aliases #name= to #element_name=' do
    node = Nokogiri::XML::Node.new 'foo', doc
    node.should respond_to :element_name=
    node.element_name.should == node.name
    node.element_name = 'bar'
    node.element_name.should == 'bar'
  end

  it 'allows symbols as hash keys for attributes' do
    attrs = Nokogiri::XML::Node.new('foo', doc)
    attrs['foo'] = 'bar'

    attrs['foo'].should == 'bar'
    attrs[:foo].should == 'bar'
  end

  it 'ensures a string is passed to the attribute setter' do
    attrs = Nokogiri::XML::Node.new('foo', doc)
    attrs[:foo] = 1
    attrs[:foo].should == '1'

    attrs[:some_attr] = :bah
    attrs[:some_attr].should == 'bah'
  end

  it 'joins an array into a string when passed to the attribute setter' do
    attrs = Nokogiri::XML::Node.new('foo', doc)
    attrs[:foo] = 1
    attrs[:foo].should == '1'

    attrs[:some_attr] = [:bah, :boo]
    attrs[:some_attr].should == 'bahboo'
  end

  it 'removes an attribute when set to nil' do
    attrs = Nokogiri::XML::Node.new('foo', doc)
    attrs['foo'] = 'bar'

    attrs['foo'].should == 'bar'
    attrs['foo'] = nil
    attrs['foo'].should be_nil
  end

  it 'allows attribute values to change' do
    attrs = Nokogiri::XML::Node.new('foo', doc)
    attrs['foo'] = 'bar'

    attrs['foo'].should == 'bar'
    attrs['foo'] = 'baz'
    attrs['foo'].should == 'baz'
  end

  it 'allows symbols as the path in #xpath' do
    node = Nokogiri::XML::Node.new('foo', doc)
    node.should respond_to :find
    doc.root = node
    doc.xpath(:foo).first.should_not be_nil
    doc.xpath(:foo).first.should == doc.xpath('/foo').first
  end

  it 'allows symbols as namespace names in #xpath' do
    node = Nokogiri::XML::Node.new('foo', doc)
    node.namespace = node.add_namespace('bar', 'baz')
    doc.root = node
    node.xpath('/bar:foo', :bar => 'baz').first.should_not be_nil
  end

  it 'aliases #xpath to #find' do
    node = Nokogiri::XML::Node.new('foo', doc)
    node.should respond_to :find
    doc.root = node
    node.find('/foo').first.should_not be_nil
  end

  it 'has a helper function #find_first' do
    node = Nokogiri::XML::Node.new('foo', doc)
    node.should respond_to :find
    doc.root = node
    node.find_first('/foo').should == node.find('/foo').first
  end
end
