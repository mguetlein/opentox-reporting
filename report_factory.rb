
# = Reports::ReportFactory 
#
# creates various reports (Reports::ReportContent) 
#
class Reports::ReportFactory
  
  RT_FASTTOX = "fasttox"
  RT_VALIDATION = "validation"
  RT_CV = "crossvalidation"
  RT_ALG_COMP = "algorithm_comparison"
  
  REPORT_TYPES = [RT_FASTTOX, RT_VALIDATION, RT_CV, RT_ALG_COMP ]
  
  # creates a report of a certain type according to the validation data in validation_set 
  #
  # call-seq:
  #   self.create_report(type, validation_set) => Reports::ReportContent
  #
  def self.create_report(type, validation_set)
    case type
    when RT_FASTTOX
      raise "not yet implemented"
    when RT_VALIDATION
      create_report_validation(validation_set)
    when RT_CV
      create_report_crossvalidation(validation_set)
    when RT_ALG_COMP
      create_report_compare_algorithms(validation_set)
    else
      raise "unknown report type"
    end
  end
  
  private
  def self.create_report_validation(validation_set)
    
    raise Reports::BadRequest.new("num validations is not equal to 1") unless validation_set.size==1

    report = Reports::ReportContent.new("Validation report")
    report.add_section_result(validation_set, VAL_ATTR_TRAIN_TEST + VAL_ATTR_CLASS, "Results", "Results")
    report.add_section_roc_plot(validation_set)
    report.add_section_confusion_matrix(validation_set.first)
    report.add_section_result(validation_set, VAL_ATTR, "All Results", "All Results")
    report.add_section_predictions( validation_set ) 
    return report
  end
  
  def self.create_report_crossvalidation(validation_set)
    
    raise Reports::BadRequest.new("num validations is not >1") unless validation_set.size>1
    raise Reports::BadRequest.new("crossvalidation-id not set in all validations") if validation_set.has_nil_values?(:cv_id)
    raise Reports::BadRequest.new("num different cross-validation-id's must be equal to 1") unless validation_set.num_different_values(:cv_id)==1
    validation_set.load_cv_attributes
    raise Reports::BadRequest.new("num validations is not equal to num folds") unless validation_set.first.CV_num_folds==validation_set.size
    raise Reports::BadRequest.new("num different folds is not equal to num validations") unless validation_set.num_different_values(:fold)==validation_set.size
    merged = validation_set.merge([:cv_id])
     
    report = Reports::ReportContent.new("Crossvalidation report")
    report.add_section_result(merged, VAL_ATTR_CV+VAL_ATTR_CLASS-["fold"],"Mean Results","Mean Results")
    report.add_section_roc_plot(validation_set)
    report.add_section_confusion_matrix(merged.first)
    report.add_section_result(validation_set, VAL_ATTR_CV+VAL_ATTR_CLASS-["CV_num_folds"], "Results","Results")
    report.add_section_result(validation_set, VAL_ATTR, "All Results", "All Results")
    report.add_section_predictions( validation_set, ["fold"] ) 
    return report
  end
  
  def self.create_report_compare_algorithms(validation_set)
    
    #validation_set.to_array([:fold, :test_dataset_uri, :model_uri]).each{|a| puts a.inspect}
    raise Reports::BadRequest.new("num validations is not >1") unless validation_set.size>1

    if validation_set.has_nil_values?(:cv_id)
      raise Reports::BadRequest.new("so far, algorithm comparison is only supported for crossvalidation results")
    else
      raise Reports::BadRequest.new("num different cross-validation-ids <2") if validation_set.num_different_values(:cv_id)<2
      validation_set.load_cv_attributes
      raise Reports::BadRequest.new("number of different algorithms <2") if validation_set.num_different_values(:CV_algorithm_uri)<2
      
      if validation_set.num_different_values(:CV_dataset_uri)>1
        raise Reports::BadRequest.new("so far, algorithm comparison is only supported for 1 dataset")
      else
        # this groups all validations in x different groups (arrays) according to there algorithm-uri
        algorithm_grouping = Reports::Util.group(validation_set.validations, ["CV_algorithm_uri"])
        # we check if there are corresponding validations in each group that have equal attributes (folds, num-folds,..)
        Reports::Util.check_group_matching(algorithm_grouping, [:fold, :CV_num_folds, :CV_dataset_uri, :CV_stratified, :CV_random_seed])
        merged = validation_set.merge([:CV_algorithm_uri]) 
        
        report = Reports::ReportContent.new("Algorithm comparison report")
        report.add_section_bar_plot(merged,"algorithm_name",VAL_ATTR_CLASS)   
        report.add_section_roc_plot(validation_set, "algorithm_name")
        report.add_section_result(merged,VAL_ATTR_CV+VAL_ATTR_CLASS-["fold"],"Mean Results","Mean Results")
        report.add_section_result(validation_set,VAL_ATTR_CV+VAL_ATTR_CLASS-["CV_num_folds"],"Results","Results")
        
        return report
      end
    end
  end
  
end

# = Reports::ReportContent
#
# wraps an xml-report, adds functionality for adding sections, adds a hash for tmp files
#
class Reports::ReportContent
  
  attr_accessor :xml_report, :tmp_files
  
  def initialize(title)
    @xml_report = XMLReport.new(title)
  end
  
  def add_section_predictions( validation_set, 
                              validation_attributes=[],
                              section_title="Predictions",
                              section_text="This section contains predictions.",
                              table_title="Predictions")
                                
    section_table = @xml_report.add_section(@xml_report.get_root_element, section_title)
    if validation_set.first.get_predictions
      @xml_report.add_paragraph(section_table, section_text) if section_text
      @xml_report.add_table(section_table, table_title, Reports::PredictionUtil.predictions_to_array(validation_set, validation_attributes))
    else
      @xml_report.add_paragraph(section_table, "No prediction info available.")
    end
  end
  
  def add_section_result( validation_set, 
                        validation_attributes,
                        table_title,
                        section_title="Results",
                        section_text="This section contains results.")
                                
    section_table = @xml_report.add_section(xml_report.get_root_element, section_title)
    @xml_report.add_paragraph(section_table, section_text) if section_text
    @xml_report.add_table(section_table, table_title, validation_set.to_array(validation_attributes))   
  end
  
  def add_section_confusion_matrix(  validation, 
                                section_title="Confusion Matrix",
                                section_text="This section contains the confusion matrix.",
                                table_title="Confusion Matrix")
                                
    section_confusion = @xml_report.add_section(xml_report.get_root_element, section_title)
    @xml_report.add_paragraph(section_confusion, section_text) if section_text
    @xml_report.add_table(section_confusion, table_title, XMLReportUtil::create_confusion_matrix(validation.class_tp, validation.class_fp, validation.class_tn, validation.class_fn), false)

  end

  def add_section_roc_plot( validation_set,
                            split_set_attribute = nil,
                            plot_file_name="roc-plot.svg", 
                            section_title="Roc Plot",
                            section_text="This section contains the roc plot.",
                            image_title="Roc Plot",
                            image_caption=nil)
    
    section_roc = @xml_report.add_section(@xml_report.get_root_element, section_title)
    if validation_set.first.get_predictions
      @xml_report.add_paragraph(section_roc, section_text) if section_text

      plot_file_path = add_tmp_file(plot_file_name)
      Reports::RPlotFactory.create_roc_plot( plot_file_path, validation_set, split_set_attribute, validation_set.size>1 )
      @xml_report.add_imagefigure(section_roc, image_title, plot_file_name, "SVG", image_caption)
    else
      @xml_report.add_paragraph(section_roc, "No prediction info for roc plot available.")
    end
    
  end
  
  def add_section_bar_plot(validation_set, 
                            title_attribute,
                            value_attributes,
                            plot_file_name="bar-plot.svg", 
                            section_title="Bar Plot",
                            section_text="This section contains the bar plot.",
                            image_title="Bar Plot",
                            image_caption=nil)
  
    section_bar = @xml_report.add_section(@xml_report.get_root_element, section_title)
    @xml_report.add_paragraph(section_bar, section_text) if section_text
    
    plot_file_path = add_tmp_file(plot_file_name)
    Reports::RPlotFactory.create_bar_plot(plot_file_path, validation_set, title_attribute, value_attributes )
    @xml_report.add_imagefigure(section_bar, image_title, plot_file_name, "SVG", image_caption)
  end  
  
  private
  def add_tmp_file(tmp_file_name)
    
    @tmp_files = {} unless @tmp_files
    raise "file name already exits" if @tmp_files[tmp_file_name] || (@text_files && @text_files[tmp_file_name])  
    tmp_file_path = Reports::Util.create_tmp_file(tmp_file_name)
    @tmp_files[tmp_file_name] = tmp_file_path
    return tmp_file_path
  end
  
end