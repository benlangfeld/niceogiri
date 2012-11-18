require 'spec_helper'

module Niceogiri
  module XML
    describe Node do
      let(:doc) { Nokogiri::XML::Document.new }

      let(:node_name) { 'foo' }
      subject { Node.new node_name }

      it 'generates a new node automatically setting the document' do
        subject.element_name.should == 'foo'
        subject.document.should_not == doc
      end

      it 'sets the new document root to the node' do
        subject.document.root.should == subject
      end

      it 'does not set the document root if the document is provided' do
        n = Node.new 'foo', doc
        n.document.root.should_not == n
      end

      it 'generates a new node with the given document' do
        n = Node.new 'foo', doc
        n.element_name.should == 'foo'
        n.document.should == doc
      end

      it 'provides an attribute reader' do
        subject.read_attr(:bar).should be_nil
        subject[:bar] = 'baz'
        subject.read_attr(:bar).should == 'baz'
      end

      it 'provides an attribute reader with conversion' do
        subject.read_attr(:bar, :to_sym).should be_nil
        subject[:bar] = 'baz'
        subject.read_attr(:bar, :to_sym).should == :baz
      end

      it 'provides an attribute writer' do
        subject[:bar].should be_nil
        subject.write_attr :bar, 'baz'
        subject[:bar].should == 'baz'
      end

      it 'provides an attribute writer with conversion' do
        subject[:bar].should be_nil
        subject.write_attr :bar, '1.0', :to_i
        subject[:bar].should == '1'
        subject.write_attr :bar, nil, :to_i
        subject[:bar].should == nil
      end

      it 'provides a content reader' do
        foo = Node.new 'foo'
        foo << (bar = Node.new('bar', foo.document))
        bar.content = 'baz'
        foo.read_content(:bar).should == 'baz'
      end

      it 'provides a content reader that converts the value' do
        foo = Node.new 'foo'
        foo << (bar = Node.new('bar', foo.document))
        bar.content = 'baz'
        foo.read_content(:bar, :to_sym).should == :baz
      end

      it 'provides a content writer' do
        foo = Node.new 'foo'
        foo.set_content_for :bar, 'baz'
        foo.content_from(:bar).should == 'baz'
      end

      it 'provides a content writer that removes a child when set to nil' do
        foo = Node.new 'foo'
        foo << (bar = Node.new('bar', foo.document))
        bar.content = 'baz'
        foo.content_from(:bar).should == 'baz'
        foo.xpath('bar').should_not be_empty

        foo.set_content_for :bar, nil
        foo.content_from(:bar).should be_nil
        foo.xpath('bar').should be_empty
      end

      it 'provides "attr_accessor" for namespace' do
        n = Node.new 'foo'
        n.namespace.should be_nil

        n.namespace = 'foo:bar'
        n.namespace_href.should == 'foo:bar'
      end

      it 'will remove a child element' do
        n = Node.new 'foo'
        n << Node.new('bar', n.document)
        n << Node.new('bar', n.document)

        n.find(:bar).size.should == 2
        n.remove_child 'bar'
        n.find(:bar).size.should == 1
      end

      it 'will remove a child with a specific xmlns' do
        n = Node.new 'foo'
        n << Node.new('bar')
        c = Node.new('bar')
        c.namespace = 'foo:bar'
        n << c

        n.find(:bar).size.should == 1
        n.find('//xmlns:bar', :xmlns => 'foo:bar').size.should == 1
        n.remove_child '//xmlns:bar', :xmlns => 'foo:bar'
        n.find(:bar).size.should == 1
        n.find('//xmlns:bar', :xmlns => 'foo:bar').size.should == 0
      end

      it 'will remove all child elements' do
        n = Node.new 'foo'
        n << Node.new('bar')
        n << Node.new('bar')

        n.find(:bar).size.should == 2
        n.remove_children 'bar'
        n.find(:bar).size.should == 0
      end

      it 'provides a copy mechanism' do
        n = Node.new 'foo'
        n2 = n.copy
        n2.object_id.should_not == n.object_id
        n2.element_name.should == n.element_name
      end

      it 'provides an inherit mechanism' do
        n = Node.new 'foo'
        n2 = Node.new 'foo'
        n2.content = 'bar'
        n2['foo'] = 'bar'

        n.inherit(n2)
        n['foo'].should == 'bar'
        n.content.should == 'bar'
        n2.to_s.should == n.to_s
      end

      it 'holds on to namespace prefixes when inheriting content' do
        n = Nokogiri::XML.parse('<message><bar:foo xmlns:bar="http://bar.com"></message>').root
        n2 = Node.new('message').inherit n
        n2.to_s.should == n.to_s
      end

      it 'holds on to namespaces when inheriting content' do
        n = Nokogiri::XML.parse('<message xmlns="foobar"><body xmlns="barfoo"/></message>').root
        n2 = Node.new('message').inherit n
        n2.to_s.should == n.to_s
        n2.namespace.href.should be == 'foobar'
        body = n2.children.first
        body.namespace.href.should be == 'barfoo'
      end

      it 'holds on to prefixed namespaces when inheriting content' do
        n = Nokogiri::XML.parse('<message xmlns:foo="foobar"></message>').root
        n.namespaces['xmlns:foo'].should be == 'foobar'

        n2 = Node.new('message').inherit n
        n2.to_s.should == n.to_s
        n2.namespaces['xmlns:foo'].should be == 'foobar'
      end

      it 'holds on to namespaces without a prefix when inheriting content' do
        n = Nokogiri::XML.parse('<message><bar:foo xmlns="http://bar.com"></message>').root
        n2 = Node.new('message').inherit n
        n2.to_s.should == n.to_s
      end

      it 'holds on to namespaces when inheriting attributes' do
        n = Nokogiri::XML.parse('<foo xml:bar="http://bar.com"/>').root
        n2 = Node.new('foo').inherit n
        n2.to_s.should == n.to_s
      end

      it 'provides a mechanism to inherit attrs' do
        n = Node.new 'foo'
        n2 = Node.new 'foo'
        n2['foo'] = 'bar'

        n.inherit_attrs(n2.attributes)
        n['foo'].should == 'bar'
      end

      it 'has a content_from helper that pulls the content from a child node' do
        f = Node.new 'foo'
        f << (b = Node.new('bar'))
        b.content = 'content'
        f.content_from(:bar).should == 'content'
      end

      it 'returns nil when sent #content_from and a missing node' do
        Node.new('foo').content_from(:bar).should be_nil
      end

      it 'creates a new node and sets content when sent #set_content_for' do
        f = Node.new 'foo'
        f.should respond_to :set_content_for
        f.xpath('bar').should be_empty
        f.set_content_for :bar, :baz
        f.xpath('bar').should_not be_empty
        f.xpath('bar').first.content.should == 'baz'
      end

      it 'removes a child node when sent #set_content_for with nil' do
        f = Node.new 'foo'
        f << (b = Node.new('bar'))
        f.should respond_to :set_content_for
        f.xpath('bar').should_not be_empty
        f.set_content_for :bar, nil
        f.xpath('bar').should be_empty
      end

      it 'will change the content of an existing node when sent #set_content_for' do
        f = Node.new 'foo'
        f << (b = Node.new('bar'))
        b.content = 'baz'
        f.should respond_to :set_content_for
        f.xpath('bar').should_not be_empty
        f.xpath('bar').first.content.should == 'baz'
        control = f.xpath('bar').first.pointer_id

        f.set_content_for :bar, 'fiz'
        f.xpath('bar').first.content.should == 'fiz'
        f.xpath('bar').first.pointer_id.should == control
      end
    end
  end
end
