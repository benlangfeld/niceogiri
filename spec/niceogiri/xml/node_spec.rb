require 'spec_helper'

module Niceogiri
  module XML
    describe Node do
      before { @doc = Nokogiri::XML::Document.new }

      it 'generates a new node automatically setting the document' do
        n = Node.new 'foo'
        n.element_name.must_equal 'foo'
        n.document.wont_equal @doc
      end

      it 'sets the new document root to the node' do
        n = Node.new 'foo'
        n.document.root.must_equal n
      end

      it 'does not set the document root if the document is provided' do
        n = Node.new 'foo', @doc
        n.document.root.wont_equal n
      end

      it 'generates a new node with the given document' do
        n = Node.new 'foo', @doc
        n.element_name.must_equal 'foo'
        n.document.must_equal @doc
      end

      it 'provides an attribute reader' do
        foo = Node.new
        foo.read_attr(:bar).must_be_nil
        foo[:bar] = 'baz'
        foo.read_attr(:bar).must_equal 'baz'
      end

      it 'provides an attribute reader with converstion' do
        foo = Node.new
        foo.read_attr(:bar, :to_sym).must_be_nil
        foo[:bar] = 'baz'
        foo.read_attr(:bar, :to_sym).must_equal :baz
      end

      it 'provides an attribute writer' do
        foo = Node.new
        foo[:bar].must_be_nil
        foo.write_attr(:bar, 'baz')
        foo[:bar].must_equal 'baz'
      end

      it 'provides a content reader' do
        foo = Node.new('foo')
        foo << (bar = Node.new('bar', foo.document))
        bar.content = 'baz'
        foo.read_content(:bar).must_equal 'baz'
      end

      it 'provides a content reader that converts the value' do
        foo = Node.new('foo')
        foo << (bar = Node.new('bar', foo.document))
        bar.content = 'baz'
        foo.read_content(:bar, :to_sym).must_equal :baz
      end

      it 'provides a content writer' do
        foo = Node.new('foo')
        foo.set_content_for :bar, 'baz'
        foo.content_from(:bar).must_equal 'baz'
      end

      it 'provides a content writer that removes a child when set to nil' do
        foo = Node.new('foo')
        foo << (bar = Node.new('bar', foo.document))
        bar.content = 'baz'
        foo.content_from(:bar).must_equal 'baz'
        foo.xpath('bar').wont_be_empty

        foo.set_content_for :bar, nil
        foo.content_from(:bar).must_be_nil
        foo.xpath('bar').must_be_empty
      end

      it 'provides "attr_accessor" for namespace' do
        n = Node.new('foo')
        n.namespace.must_be_nil

        n.namespace = 'foo:bar'
        n.namespace_href.must_equal 'foo:bar'
      end

      it 'will remove a child element' do
        n = Node.new 'foo'
        n << Node.new('bar', n.document)
        n << Node.new('bar', n.document)

        n.find(:bar).size.must_equal 2
        n.remove_child 'bar'
        n.find(:bar).size.must_equal 1
      end

      it 'will remove a child with a specific xmlns' do
        n = Node.new 'foo'
        n << Node.new('bar')
        c = Node.new('bar')
        c.namespace = 'foo:bar'
        n << c

        n.find(:bar).size.must_equal 1
        n.find('//xmlns:bar', :xmlns => 'foo:bar').size.must_equal 1
        n.remove_child '//xmlns:bar', :xmlns => 'foo:bar'
        n.find(:bar).size.must_equal 1
        n.find('//xmlns:bar', :xmlns => 'foo:bar').size.must_equal 0
      end

      it 'will remove all child elements' do
        n = Node.new 'foo'
        n << Node.new('bar')
        n << Node.new('bar')

        n.find(:bar).size.must_equal 2
        n.remove_children 'bar'
        n.find(:bar).size.must_equal 0
      end

      it 'provides a copy mechanism' do
        n = Node.new 'foo'
        n2 = n.copy
        n2.object_id.wont_equal n.object_id
        n2.element_name.must_equal n.element_name
      end

      it 'provides an inherit mechanism' do
        n = Node.new 'foo'
        n2 = Node.new 'foo'
        n2.content = 'bar'
        n2['foo'] = 'bar'

        n.inherit(n2)
        n['foo'].must_equal 'bar'
        n.content.must_equal 'bar'
        n2.to_s.must_equal n.to_s
      end

      it 'holds on to namespaces when inheriting content' do
        n = Nokogiri::XML.parse('<message><bar:foo xmlns:bar="http://bar.com"></message>').root
        n2 = Node.new('message').inherit n
        n2.to_s.must_equal n.to_s
      end

      it 'provides a mechanism to inherit attrs' do
        n = Node.new 'foo'
        n2 = Node.new 'foo'
        n2['foo'] = 'bar'

        n.inherit_attrs(n2.attributes)
        n['foo'].must_equal 'bar'
      end

      it 'has a content_from helper that pulls the content from a child node' do
        f = Node.new('foo')
        f << (b = Node.new('bar'))
        b.content = 'content'
        f.content_from(:bar).must_equal 'content'
      end

      it 'returns nil when sent #content_from and a missing node' do
        f = Node.new('foo')
        f.content_from(:bar).must_be_nil
      end

      it 'creates a new node and sets content when sent #set_content_for' do
        f = Node.new('foo')
        f.must_respond_to :set_content_for
        f.xpath('bar').must_be_empty
        f.set_content_for :bar, :baz
        f.xpath('bar').wont_be_empty
        f.xpath('bar').first.content.must_equal 'baz'
      end

      it 'removes a child node when sent #set_content_for with nil' do
        f = Node.new('foo')
        f << (b = Node.new('bar'))
        f.must_respond_to :set_content_for
        f.xpath('bar').wont_be_empty
        f.set_content_for :bar, nil
        f.xpath('bar').must_be_empty
      end

      it 'will change the content of an existing node when sent #set_content_for' do
        f = Node.new('foo')
        f << (b = Node.new('bar'))
        b.content = 'baz'
        f.must_respond_to :set_content_for
        f.xpath('bar').wont_be_empty
        f.xpath('bar').first.content.must_equal 'baz'
        control = f.xpath('bar').first.pointer_id

        f.set_content_for :bar, 'fiz'
        f.xpath('bar').first.content.must_equal 'fiz'
        f.xpath('bar').first.pointer_id.must_equal control
      end
    end
  end
end
