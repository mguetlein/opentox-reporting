
# = Reports::ReportService
#
# provides complete report webservice functionality
#
class Reports::ReportService

  # lists all available report types, returns list of uris
  #
  # call-seq:
  #   get_report_types => string
  #
  def get_report_types
    
    LOGGER.info "list all report types"
    Reports::ReportFactory::REPORT_TYPES.collect{ |t| get_uri(t) }.join("\n")
  end
  
  # lists all stored reports of a certain type, returns a list of uris
  #
  # call-seq:
  #   get_all_reports(type) => string
  #
  def get_all_reports(type)
    
    LOGGER.info "get all reports of type '"+type.to_s+"'"
    check_report_type(type)
    REPORT_PERSISTANCE.list_reports(type).collect{ |id| get_uri(type,id) }.join("\n")
  end
  
  # creates a report of a certain type, __uri_list__ must contain be a list of validation or cross-validation-uris
  # returns the uir of the report 
  #
  # call-seq:
  #   create_report(type, uri_list) => string
  # 
  def create_report(type, uri_list)
    
    LOGGER.info "create report of type '"+type.to_s+"'"
    check_report_type(type)
    
    # step1: load validations
    validation_set = Reports::ValidationSet.new(uri_list)
    raise Reports::BadRequest.new("no validations found") unless validation_set and validation_set.size > 0
    LOGGER.debug "loaded "+validation_set.size.to_s+" validation/s"
    
    #step 2: create report of type
    report_content = Reports::ReportFactory.create_report(type, validation_set)
    LOGGER.debug "report created"
    
    #step 3: persist report if creation not failed
    id = REPORT_PERSISTANCE.new_report(report_content, type)
    LOGGER.debug "report persisted with id: '"+id.to_s+"'"
    
    return get_uri(type, id)
  end
  
  # returns report in a certain format, converts to this format if not yet exists, return uri of report on server 
  #
  # call-seq:
  #   get_report( type, id, format ) => string
  # 
  def get_report( type, id, format )
    
    LOGGER.info "get report '"+id.to_s+"' of type '"+type.to_s+"' (format: '"+format+"')"
    
    format.upcase!
    raise Reports::BadRequest.new("report format not supported '"+format.to_s+"', supported formats are "+
      Reports::ReportFormat::REPORT_FORMATS.inspect) unless Reports::ReportFormat::REPORT_FORMATS.index(format)
    
    result = REPORT_PERSISTANCE.get_report(type, id, format)
    raise_not_found( type, id ) unless result
    return get_base_uri+"/"+result
  end
  
  def delete_report( type, id )
    
    LOGGER.info "delete report '"+id.to_s+"' of type '"+type.to_s+"'"
    raise_not_found( type, id) unless REPORT_PERSISTANCE.delete_report(type, id)
  end
  
  def parse_type( report_uri )
    
    raise "invalid uri" unless report_uri.to_s =~/^#{get_base_uri}.*/
    type = report_uri.squeeze("/").split("/")[-2]
    check_report_type(type)
    return type
  end
  
  def parse_id( report_uri )
    
    raise "invalid uri" unless report_uri.to_s =~/^#{get_base_uri}.*/
    id = report_uri.squeeze("/").split("/")[-1]
    REPORT_PERSISTANCE.check_report_id_format(id)
    return id
  end
  
  protected
  def get_base_uri
    #PENDING replace with get uri method
    "file://home/martin/tmp/reports"
  end
  
  def raise_not_found(type, id)
    raise Reports::NotFound.new("report not found, type:'"+type.to_s+"', id:'"+id.to_s+"'")
  end
  
  def get_uri(type, id=nil)
    get_base_uri+"/"+type.to_s+(id!=nil ? "/"+id.to_s : "")
  end
  
  def check_report_type(type)
   raise Reports::NotFound.new("report type not found '"+type.to_s+"''") unless Reports::ReportFactory::REPORT_TYPES.index(type)
  end
  
end

class Reports::LoggedException < Exception
  
  def initialize(message)
    super(message)
    LOGGER.error(message)
  end
  
end

# corresponds to 400
#
class Reports::BadRequest < Reports::LoggedException
  
end

# corresponds to 404
#
class Reports::NotFound < Reports::LoggedException
  
end

