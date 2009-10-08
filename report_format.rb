
# = Reports::ReportFormat
# 
# provides functions for converting reports from xml to other formats
#
class Reports::ReportFormat
  
  RF_HTML = "HTML"
  REPORT_FORMATS = [RF_HTML]
  
  # formats a report from xml into __format__
  # * xml report must be in __directory__ with filename __xml_filename__
  # * the new format can be found in __dest_filame__
  def self.format_report(directory, xml_filename, dest_filename, format)
    
    raise "directory does not exist: "+directory.to_s unless File.directory?directory.to_s
    xml_file = directory.to_s+"/"+xml_filename.to_s
    raise "xml file not found: "+xml_file unless File.exist?xml_file
    dest_file = directory.to_s+"/"+dest_filename.to_s
    raise "destination file already exists: "+dest_file if File.exist?dest_file
    
    case format
    when RF_HTML
      format_report_to_html(directory, xml_filename, dest_filename)
    else
      raise "unknown format type"
    end
  end
  
  private
  def self.format_report_to_html(directory, xml_filename, html_filename)
    
    cmd = "saxon-xslt -o " + html_filename.to_s+" "+xml_filename.to_s+" "+ENV['REPORT_XSL']
    LOGGER.debug "converting report to html: '"+cmd+"'"
    #LOGGER.debug "- working directory is '"+directory+"'"
    Dir.chdir directory.to_s do
      IO.popen(cmd.to_s) do |f|
        while line = f.gets do
          LOGGER.info "saxon-xslt> "+line 
        end
      end 
    end
  end
  
end