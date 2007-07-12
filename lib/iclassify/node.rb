require 'rubygems'
require 'rexml/document'
require 'builder'

module IClassify
  class Node
    attr_accessor :tags, :uuid, :description, :notes, :attribs, :node_id
    
    def initialize(xml=nil)
      from_xml(xml) if xml
      @tags ||= Array.new
      @attribs ||= Array.new
    end

    def self.from_search(doc)
      xml = REXML::Document.new(doc)
      node_array = Array.new
      xml.elements.each("//node") do |node|
        node_array << Node.new(node)
      end
      node_array
    end
    
    def to_xml
      xml = Builder::XmlMarkup.new
      output = xml.node do
        xml.id(@node_id) if @node_id
        xml.uuid(@uuid)
        xml.description(@description)
        xml.notes(@notes)
        xml.tags do
          @tags.each do |tag|
            xml.tag(tag)
          end
        end
        xml.attribs do
          @attribs.each do |attrib|
            xml.attrib do
              xml.name(attrib[:name])
              xml.values do
                attrib[:values].each do |v|
                  xml.value(v)
                end
              end
            end
          end
        end
      end
      output
    end
    
    def to_s(tags=nil,attribs=nil)
      output = String.new
      output << "uuid: #{@uuid}\n"
      output << "node_id: #{@node_id}\n"
      output << "notes: #{@notes}\n"
      output << "description: #{@description}\n"
      output << "tags: #{@tags.join(' ')}\n"
      output << "attribs:\n"
      @attribs.each do |attrib|
        output << "  #{attrib[:name]}: #{attrib[:values].join(', ')}\n"
      end
      output
    end
        
    def from_xml(doc)
      xml = nil
      if doc.kind_of?(REXML::Element)
        xml = doc
      else
        xml = REXML::Document.new(doc)
      end
      @tags = xml.elements.collect('//tag') { |t| t.text }
      @uuid = xml.get_text('//uuid')
      @node_id   = xml.get_text('//id')
      @description = xml.get_text('//description')
      @notes = xml.get_text('//notes')
      @attribs = Array.new
      xml.elements.each('//attrib') do |attrib|
        cattrib = Hash.new
        cattrib[:name] = attrib.get_text('name').to_s
        cattrib[:values] = attrib.elements.collect('values/value') { |v| v.text }
        @attribs << cattrib
      end
    end
      
  end
end
