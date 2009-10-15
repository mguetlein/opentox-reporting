
# these are all attributes are stored in the validation object, the attributes that start with CV are initially not set
VAL_ATTR = [ # general validation attributes
             "id", "name", "uri", "model_uri", "test_dataset_uri", "prediction_dataset_uri",
             "datetime", "elapsed_time_testing", "cpu_time_testing", "cv_id", "fold",
             # classification attributes
             "class_auc", "class_acc", "class_tp", "class_fp", "class_tn", "class_fn",
             # regression attributes
             "reg_mae",
             # not part of the valdiation object, must be derieved from the model
             "algorithm_name", "training_dataset_name", "test_dataset_name",
             # crossvalidation attributes
             "CV_num_folds", "CV_algorithm_uri", "CV_dataset_uri", "CV_stratified", "CV_random_seed",
             # not part of the crossvalidation object
             "CV_dataset_name" ]
# the variance is computed when merging results for these attributes 
VAL_ATTR_VARIANCE = [ "class_auc", "class_acc",
                      "reg_mae" ]
# selected attributes of interest when generating the report for a train-/test-evaluation                      
VAL_ATTR_TRAIN_TEST = [ "algorithm_name", "training_dataset_name", "test_dataset_name" ]
# selected attributes of interest when generating the crossvalidation report
VAL_ATTR_CV = [ "algorithm_name", "CV_dataset_name", "CV_num_folds", "fold" ]
# selected attributes of interest when performing classification
VAL_ATTR_CLASS = [ "class_auc", "class_acc" ]
# selected attributes of interest when performing regression
VAL_ATTR_REG = [ "reg_mae" ]

# colors for r-plots
R_PLOT_COLORS = ["red", "blue", "green", "yellow"]

# the r-path has to be added for the rinruby plugin
ENV['PATH'] = "/home/martin/software/R-2.8.0/bin:"+ENV['PATH']
# graph-files are generated in the tmp-dir before they are stored
ENV['TMP_DIR'] = "/home/martin/tmp" unless ENV['TMP_DIR']
ENV['REPORT_XSL'] = "/usr/share/xml/docbook/stylesheet/nwalsh/html/docbook.xsl" unless ENV['REPORT_XSL'] 
ENV['REPORT_DTD'] = "/usr/share/xml/docbook/schema/dtd/4.1/docbookx.dtd" unless ENV['REPORT_DTD'] 

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
# service for communication with the other webservice compounds
OT_ACCESS = Reports::OTMockLayer.new
# service for persisting reports
REPORT_PERSISTANCE = Reports::FileReportPersistance.new("/home/martin/tmp/reports")
