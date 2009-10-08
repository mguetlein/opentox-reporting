load "environment.rb"

require 'test/unit'

class Reports::ReportServiceTest < Test::Unit::TestCase
  
  def test_service
    
    rep = Reports::ReportService.new
    
    types = rep.get_report_types
    assert types.is_a?(String)
    assert types.split("\n").size == Reports::ReportFactory::REPORT_TYPES.size
    
    Reports::ReportFactory::REPORT_TYPES.each{|t| rep.get_all_reports(t)}
    assert_raise(Reports::NotFound){rep.get_all_reports("osterhase")}
    
    assert_raise(Reports::BadRequest){report_uri = rep.create_report("validation", ["validation_uri_1","validation_uri_2"])}
    report_uri = rep.create_report("validation", ["validation_uri_1"])
    type = rep.parse_type(report_uri)
    id = rep.parse_id(report_uri)
    assert_raise(Reports::BadRequest){rep.get_report(type, id, "weihnachtsmann")}
    rep.get_report(type, id, "html")
    assert_raise(Reports::NotFound){rep.delete_report(type, 877658)}
    rep.delete_report(type, id)
    
    OT_ACCESS.reset
    report_uri = rep.create_report("crossvalidation", ["validation_uri_1","validation_uri_2", "validation_uri_3", "validation_uri_4", "validation_uri_5"])
    type = rep.parse_type(report_uri)
    id = rep.parse_id(report_uri)
    rep.delete_report(type, id)
    
    OT_ACCESS.reset
    report_uri = rep.create_report("algorithm_comparison", ["validation_uri"] * (Reports::OTMockLayer::NUM_DATASETS * Reports::OTMockLayer::NUM_ALGS * Reports::OTMockLayer::NUM_FOLDS))
    type = rep.parse_type(report_uri)
    id = rep.parse_id(report_uri)
    rep.delete_report(type, id)
  end

end


class Reports::XMLReportTest < Test::Unit::TestCase
  
  def test_all
    
    rep = XMLReport.new("a","b","c")
    section1 = rep.add_section(rep.get_root_element, "d")
    rep.add_paragraph(section1, "e")
    rep.add_imagefigure(section1, "f", "g", "h", "i")
    section2 = rep.add_section(rep.get_root_element,"j")
    rep.add_section(section2,"k")
    rep.add_table( section2, "l", [["m","n","o"],[1,2,3],[4,5,6]] )
    rep.add_list( section2, [1,2,3,4,5])
    res = ""
    rep.write_to(res)
    assert res.length > 0
    assert_equal(res.count("<"), res.count(">")) 
  end

end


class Reports::XMLReportUtilTest < Test::Unit::TestCase
  
  def test_create_matrix
    
    matrix = XMLReportUtil.create_confusion_matrix(1,2,3,4)
    assert matrix.is_a?(Array)
    assert matrix[0].is_a?(Array)
  end
  
end

class Reports::RPlotTest < Test::Unit::TestCase
  
  def test_bar_plot
    test_plot(lambda{|tmp_file| Reports::RPlotFactory.demo_bar_plot(tmp_file)})
  end
  
  def test_roc_plot
    test_plot(lambda{|tmp_file| Reports::RPlotFactory.demo_roc_plot(tmp_file)})
  end
  
  private
  def test_plot(build_plot)
    
    tmp_file = Reports::Util.create_tmp_file("roc.svg")
    assert !File.exist?(tmp_file)
    build_plot.call(tmp_file)
    assert File.exist?(tmp_file)
    FileUtils.rm(tmp_file)
    assert !File.exist?(tmp_file)
    
  end
    
  
end

class Reports::UtilTest < Test::Unit::TestCase
  
  class Person
    attr_accessor :name, :age, :gender
    
    def initialize(name, age, gender)
      @name = name
      @age = age
      @gender = gender
    end
    
    def to_s
      return @name.to_s+" "+@age.to_s+" "+@gender.to_s
    end
  end
  
  def test_grouping
    
    people = [ Person.new("Ralf",20,"m"),
               Person.new("Eva",21,"f"),
               Person.new("Adam",21,"m"),
               Person.new("Rolf",20,"m")]
               
    grouping = Reports::Util.group(people, ["gender"])
    assert grouping.size == 2
    assert grouping[0].size == 3
    assert grouping[1].size == 1
    
    people = [ Person.new("Tom",20,"m"),
               Person.new("Manu",21,"m"),
               Person.new("Konni",22,"m"),
               Person.new("Tom",20,"f"),
               Person.new("Manu",21,"f"),
               Person.new("Konni",22,"f")]
    
    grouping = Reports::Util.group(people, ["gender"])
    assert grouping.size == 2
    assert grouping[0].size == 3
    assert grouping[1].size == 3
    
    Reports::Util.check_group_matching( grouping, ["name", "age" ])
    
  end
  
end