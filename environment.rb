
# the r-path has to be added for the rinruby plugin
raise "Environment variable R_HOME missing" unless ENV['R_HOME']
ENV['PATH'] = ENV['R_HOME']+":"+ENV['PATH'] unless ENV['PATH'].split(":").index(ENV['R_HOME'])

require 'rubygems'
require "rinruby"
R.eval("library(ROCR)", false)
require 'logger'
require 'rexml/document'
require 'fileutils'
require 'tempfile'
require 'sinatra'
require 'sinatra/url_for' 
require 'sinatra/respond_to'
require 'rest_client'
require 'yaml'
require 'opentox-ruby-api-wrapper'
require 'fileutils'
require 'opentox-validation-lib'

include REXML

module Reports
end

load "r_plot_factory.rb"
load "xml_report.rb"
load "xml_report_util.rb"
load "report_persistance.rb"
load "report_factory.rb"
load "report_service.rb"
load "report_format.rb"
load "ot_access.rb"
load "validation_data.rb"
load "predictions.rb"
load "util.rb"
load "external/mimeparse.rb"

LOGGER = Logger.new(STDOUT)
LOGGER.datetime_format = "%Y-%m-%d %H:%M:%S "

module Reports
  
  def self.ot_access
    @@ot_access
  end
  
  def self.reset_ot_access
    @@ot_access = ENV['USE_OT_MOCK_LAYER'] ? Reports::OTMockLayer.new : Reports::OTWebserviceAccess.new
  end
  
  # initialize ot_access
  reset_ot_access
end

