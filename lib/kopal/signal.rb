#Objects, which hold the response or data to be transmitted via Kopal::Antenna
module Kopal::Signal
  include KopalHelper

  def headers
    @headers_
  end
end

class Kopal::Signal::Request
  include Kopal::Signal
  attr_accessor :uri, :http_method

  def initialize request_uri
    @uri = URI.parse(request_uri)
    @http_method = 'GET'
    @headers_ = {}
  end
end

class Kopal::Signal::Response
  include Kopal::Signal #makes me.is_a? Kopal::Signal

  #Some kind of Rails deprecation warning for @response and @headers
  #Response is a Net::HTTPResponse object
  def initialize response
    @response_ = response
    @headers_ = @response_.to_hash
  end

  def response
    @response_
  end
  
  #Returns true if body is an XML with root element Kopal
  def kopal_discovery?
    body_xml? && body_xml.root.name == 'Kopal' &&
      kopal_revision #Make sure it is present
  end
  
  #Returns true if body is an XML with root element KopalFeed.
  #Raises Kopal::KopalXmlError if required attributes are not present.
  def kopal_feed?
    body_xml? && body_xml.root.name == "KopalFeed" &&
      kopal_revision
  end
  
  def body_raw
    @response_.body
  end

  def body_xml?
    !body_xml.root.nil?
  end
  
  def body_xml
    @body_xml ||= body_xml!
  end

  #Bypass cache
  def body_xml!
    @body_xml = REXML::Document.new(body_raw)
  end

  #returns nil if not present
  def kopal_platform
    begin
     return body_xml.root.attributes['platform']
    rescue => e
      raise Kopal::KopalXmlError, "Not a valid Kopal XML stream."
    end
  end

  #returns Kopal::KopalXmlError if not present
  def kopal_revision
    begin
     raise if body_xml.root.attributes['revision'].blank?
     return body_xml.root.attributes['revision']
    rescue => e
      raise Kopal::KopalXmlError, "Not a valid Kopal XML stream."
    end
  end
  
end
