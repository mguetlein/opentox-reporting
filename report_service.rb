
# = Reports::ReportService
#
# provides complete report webservice functionality
#
class Reports::ReportService
  
  def initialize(home_uri)
    LOGGER.info "init report service"
    @home_uri = home_uri
  end

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
  
  # yields report in a certain format, converts to this format if not yet exists, returns uri of report on server 
  #
  # call-seq:
  #   get_report( type, id, accept_header_value ) => string
  # 
  def get_report( type, id, accept_header_value="text/xml" )
    
    LOGGER.info "get report '"+id.to_s+"' of type '"+type.to_s+"' (accept-header-value: '"+accept_header_value.to_s+"')"
    
    format = Reports::ReportFormat.get_format(accept_header_value)
    return REPORT_PERSISTANCE.get_report(type, id, format)
  end
  
  # returns a report resource (i.e. image)
  #
  # call-seq:
  #   get_report_resource( type, id, resource ) => string
  # 
  def get_report_resource( type, id, resource )
    
    LOGGER.info "get resource '"+resource+"' for report '"+id.to_s+"' of type '"+type.to_s+"'"
    return REPORT_PERSISTANCE.get_report_resource(type, id, resource)
  end
  
  
  # delets a report
  #
  # call-seq:
  #   delete_report( type, id )
  # 
  def delete_report( type, id )
    
    LOGGER.info "delete report '"+id.to_s+"' of type '"+type.to_s+"'"
    REPORT_PERSISTANCE.delete_report(type, id)
  end
  
  def parse_type( report_uri )
    
    raise "invalid uri" unless report_uri.to_s =~/^#{@home_uri}.*/
    type = report_uri.squeeze("/").split("/")[-2]
    check_report_type(type)
    return type
  end
  
  def parse_id( report_uri )
    
    raise "invalid uri" unless report_uri.to_s =~/^#{@home_uri}.*/
    id = report_uri.squeeze("/").split("/")[-1]
    REPORT_PERSISTANCE.check_report_id_format(id)
    return id
  end
  
  protected
  def get_uri(type, id=nil)
    @home_uri+"/"+type.to_s+(id!=nil ? "/"+id.to_s : "")
  end
  
  def check_report_type(type)
   raise Reports::NotFound.new("report type not found '"+type.to_s+"'") unless Reports::ReportFactory::REPORT_TYPES.index(type)
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

