
# = Reports::ReportPersistance
#
# service that stores reports (Reports::ReportConent), and provides access in various formats
#
class Reports::ReportPersistance
  
  # lists all stored report ID-s of a certain type
  #
  # call-seq:
  #   list_reports(type) => Array
  #
  def list_reports(type)
    raise "not implemented"
  end
  
  # stores content of a report (Reports::ReportContent) and returns id
  #
  # call-seq:
  #   new_report(report_content) => string
  #
  def new_report(report_content)
    raise "not implemented"
  end
  
  # returns a already created report in a certain format (converts to this format if it does not exist yet)
  # * PRENDING: unclear how the result should look like, url??
  #
  # call-seq:
  #   get_report(type, id, format) => string
  #
  def get_report(type, id, format)
    raise "not implemented"
  end
  
  # deletes a report
  # * returns true if deleting successfull
  # * returns false if report not found
  # * raises exception if error occurs
  #
  # call-seq:
  #   delete_report(type, id) => boolean
  #
  def delete_report(type, id)
    raise "not implemented"
  end
  
  # raises exception if not valid id format
  def check_report_id_format(id)
    raise "not implemented"
  end
  
end

# = Reports::FileReportPersistance
#
# type of Reports::ReportPersistance, stores reports in file-system, see Reports::ReportPersistance for API documentation
#
class Reports::FileReportPersistance < Reports::ReportPersistance
  
  def initialize(report_dir="/tmp/reports")
    @report_dir = report_dir  
    FileUtils.mkdir @report_dir.to_s unless File.directory?(@report_dir)
    raise "report cannot be found nor created" unless File.directory?(@report_dir)
  end
  
  def list_reports(type)
    (Dir.new(type_directory(type)).entries - [".", ".."]).sort{|x,y| x.to_i <=> y.to_i}
  end
  
  def new_report(report_content, type)
    
    LOGGER.debug "storing new report of type "+type.to_s 
    
    type_dir = type_directory(type)
    raise "type dir '"+type_dir+"' cannot be found nor created" unless File.directory?(type_dir)
    
    id = 1
    while File.exist?( type_dir+"/"+id.to_s )
      id += 1
    end
    report_dir = type_dir+"/"+id.to_s
    FileUtils.mkdir(report_dir)
    raise "report dir '"+report_dir+"' cannot be created" unless File.directory?(report_dir)
    
    xml_filename = report_dir+"/report.XML"
    xml_file = File.new(xml_filename, "w")
    report_content.xml_report.write_to(xml_file)
    xml_file.close
    if (report_content.tmp_files)
      report_content.tmp_files.each do |k,v|
        tmp_filename = report_dir+"/"+k
        raise "tmp-file '"+tmp_filename.to_s+"' already exists" if File.exist?(tmp_filename)
        raise "tmp-file '"+v.to_s+"' not found" unless File.exist?(v)
        FileUtils.mv(v.to_s,tmp_filename)
        raise "could not move tmp-file to '"+tmp_filename.to_s+"'" unless File.exist?(tmp_filename)
      end
    end
    return id
  end
  
  def get_report(type, id, format)
    
    report_dir = report_directory(type, id)
    return nil unless File.directory?(report_dir)
    
    filename = "report."+format
    file_path = report_dir+"/"+filename
    if !File.exist?(file_path)
      Reports::ReportFormat.format_report(report_dir, "report.XML", filename, format)
      raise "formated file not found '"+file_path+"'" unless File.exist?(file_path)
    end
    
    return type+"/"+id.to_s+"/"+"report."+format
    #return "file:/"+file_path 
  end
  
  def delete_report(type, id)
    
    report_dir = report_directory(type, id)
    return false unless File.directory?(report_dir)
    
    entries = (Dir.new(report_dir).entries-[".", ".."]).collect{|f| report_dir+"/"+f.to_s}
    FileUtils.rm(entries)
    FileUtils.rmdir report_dir
    raise "could not delete report directory '"+report_dir+"'" if File.directory?(report_dir)
    return true
  end
  
  def check_report_id_format(id)
    raise "not valid report id format" unless id.to_s =~ /[0-9]+/
  end
  
  private
  def type_directory(type)
    dir = @report_dir+"/"+type
    FileUtils.mkdir dir.to_s unless (File.directory?(dir))
    return dir
  end
  
  def report_directory(type, id)
    type_dir = type_directory(type)
    raise "type dir '"+type_dir+"' cannot be found nor created" unless File.directory?(type_dir)
    return type_dir+"/"+id.to_s
  end
  
end
