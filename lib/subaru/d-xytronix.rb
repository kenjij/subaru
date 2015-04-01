require 'open-uri'
require 'uri'
require 'rexml/document'


module Subaru

  module Definitions

    module Xytronix

      module Common
        attr_accessor :options

        # @param url [String] device url; e.g., `http://10.1.1.11:8888`.
        # @param opts [Hash] the device options.
        def initialize(opts = {})
          @options = opts
        end

        # Generate query string.
        # @param query_hash [hash] resources and their state to set to.
        # @return [String] query string.
        def generate_query(query_hash)
          return nil unless query_hash.class == Hash
          h = {}
          query_hash.each do |k, v|
            case v
            when "off"
              h["#{k}State"] = 0
            when "on"
              h["#{k}State"] = 1
            end
          end
          return nil if h.empty?
          return URI.encode_www_form(h)
        end

        # Access the device.
        # @param query [String] encoded query string.
        # @return [Object] XML document returned from the device.
        def send_request(query = nil)
          uri = "#{@options[:url]}/stateFull.xml"
          uri << "?#{query}" if query
          o = {}
          o[:http_basic_authentication] = [nil, @options[:password]] if @options[:password]
          o[:read_timeout] = @options[:read_timeout] if @options[:read_timeout]
          response = open(uri, o)
          return REXML::Document.new(response.read)
        rescue => e
          puts e.message
          return nil
        end

        # Search the XML document.
        # @param doc [Object] XML document.
        # @param resource [String] resource name to search.
        # @param ch [Fixnum] resource channel number.
        # @return [String] state of the resource; e.g., `on`, `off`.
        def state_from_xml(doc, resource, ch = nil)
          case REXML::XPath.first(doc, "//datavalues/#{resource}#{ch}state").text.to_i
          when 0
            s = "off"
          when 1
            s = "on"
          else
            s = "unknown"
          end
          return s
        rescue => e
          puts e.message
          return nil
        end

      end

      class WebRelay
        include Common

        # Read resources from device.
        # @return [Hash] resources and their state.
        def read
          return parse_xml(send_request)
        end

        # Set resource state of a device.
        # @param data [String] POST/PUT data.
        # @return [Hash] resulting resources and their state.
        def write(data)
          q = generate_query(JSON.parse(data))
          return nil unless q
          return parse_xml(send_request(q))
        rescue => e
          puts e.message
          return nil
        end

        # Parse XML document response.
        # @param xml [Object] XML document.
        # @return [Hash]
        def parse_xml(xml)
          results = {}
          ['relay', 'input'].each do |r|
            results[r] = state_from_xml(xml, r)
          end
          return results
        rescue => e
          puts e.message
          return nil
        end

      end

      class WebRelay10
        include Common

        # Read resources from device.
        # @return [Hash] resources and their state.
        def read
          return parse_xml(send_request)
        end

        # Set resource state of a device.
        # @param data [String] POST/PUT data.
        # @return [Hash] resulting resources and their state.
        def write(data)
          q = generate_query(JSON.parse(data))
          return nil unless q
          return parse_xml(send_request(q))
        rescue => e
          puts e.message
          return nil
        end

        # Parse XML document response.
        # @param xml [Object] XML document.
        # @return [Hash]
        def parse_xml(xml)
          results = {}
          (1..10).each do |ch|
            results["relay#{ch}"] = state_from_xml(xml, 'relay', ch)
          end
          return results
        rescue => e
          puts e.message
          return nil
        end

      end

    end

  end

end
