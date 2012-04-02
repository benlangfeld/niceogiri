require 'spec_helper'

describe Nokogiri::XML::Node do
  let(:doc) { Nokogiri::XML::Document.new }

  subject { Nokogiri::XML::Node.new 'foo', doc }

  before { doc.root = subject }

  it 'aliases #name to #element_name' do
    subject.should respond_to :element_name
    subject.element_name.should == subject.name
  end

  it 'aliases #name= to #element_name=' do
    subject.should respond_to :element_name=
    subject.element_name.should == subject.name
    subject.element_name = 'bar'
    subject.element_name.should == 'bar'
  end

  it 'allows symbols as hash keys for attributes' do
    subject['foo'] = 'bar'
    subject['foo'].should == 'bar'
    subject[:foo].should == 'bar'
  end

  it 'ensures a string is passed to the attribute setter' do
    subject[:foo] = 1
    subject[:foo].should == '1'

    subject[:some_attr] = :bah
    subject[:some_attr].should == 'bah'
  end

  it 'joins an array into a string when passed to the attribute setter' do
    subject[:foo] = 1
    subject[:foo].should == '1'

    subject[:some_attr] = [:bah, :boo]
    subject[:some_attr].should == 'bahboo'
  end

  it 'removes an attribute when set to nil' do
    subject['foo'] = 'bar'
    subject['foo'].should == 'bar'
    subject['foo'] = nil
    subject['foo'].should be_nil
  end

  it 'allows attribute values to change' do
    subject['foo'] = 'bar'
    subject['foo'].should == 'bar'
    subject['foo'] = 'baz'
    subject['foo'].should == 'baz'
  end

  it 'allows symbols as the path in #xpath' do
    subject.should respond_to :find
    doc.root = subject
    doc.xpath(:foo).first.should_not be_nil
    doc.xpath(:foo).first.should == doc.xpath('/foo').first
  end

  it 'allows symbols as namespace names in #xpath' do
    subject.namespace = subject.add_namespace('bar', 'baz')
    doc.root = subject
    subject.xpath('/bar:foo', :bar => 'baz').first.should_not be_nil
  end

  it 'aliases #xpath to #find' do
    subject.should respond_to :find
    doc.root = subject
    subject.find('/foo').first.should_not be_nil
  end

  it 'has a helper function #find_first' do
    subject.should respond_to :find
    doc.root = subject
    subject.find_first('/foo').should == subject.find('/foo').first
  end
end
