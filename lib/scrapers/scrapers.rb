dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require 'logger'
require 'nokogiri'
require 'typhoeus'
require 'colorize'

module Scrapers
  class NoPageProcessorFoundError < StandardError; end
  class InvalidProcessorError < StandardError; end

  def self.logger
    @logger ||= begin
      logfile = File.open('scrapers.log', 'a') # create log file
      logfile.sync = true  # automatically flushes data to file
      Logger.new(logfile)
    end
  end
end

require 'scrapers/base_page_processor'
require 'scrapers/scrap_request'
require 'scrapers/loader'
