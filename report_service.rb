
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
    if validation_set==nil or validation_set.size < 1
      err = "no validations found"
      LOGGER.error(err)
      raise BadRequest.new(err.to_s)
    end
    LOGGER.debug "loaded "+validation_set.size.to_s+" validation/s"
    
    #step 2: create report of type
    report_content = Reports::ReportFactory.create_report(type, validation_set)
    if report_content==nil or report_content.xml_report==nil
      err = "could not create report"
      LOGGER.error(err)
      raise err #runtime exception ~= internal error
    end
    LOGGER.debug "report created"
    
    #step 3: persist report if creation not failed
    id = REPORT_PERSISTANCE.new_report(report_content, type)
    if id == nil
      err = "could not persist report"
      LOGGER.error(err)
      raise err #runtime exception ~= internal error
    end
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
    if Reports::ReportFormat::REPORT_FORMATS.index(format) == nil
      err = "report format not supported '"+format.to_s+"', supported formats are "+ReportFormat.get_report_formats.inspect
      LOGGER.error(err)
      raise BadRequest.new(err)
    end
    
    result = REPORT_PERSISTANCE.get_report(type, id, format)
    raise_not_found( type, id ) unless result
    return get_base_uri+"/"+result
  end
  
  def delete_report( type, id )
    
    LOGGER.info "delete report '"+id.to_s+"' of type '"+type.to_s+"'"
    raise_not_found( type, id) unless REPORT_PERSISTANCE.delete_report(type, id)
  end
  
  protected
  def get_base_uri
    #PENDING replace with get uri method
    "file://home/martin/tmp/reports"
  end
  
  def raise_not_found(type, id)
    err = "report not found, type:'"+type.to_s+"', id:'"+id.to_s+"'"
    LOGGER.error(err)
    raise NotFound.new(err)
  end
  
  def get_uri(type, id=nil)
    get_base_uri+"/"+type.to_s+(id!=nil ? "/"+id.to_s : "")
  end
  
  def check_report_type(type)
    
    if Reports::ReportFactory::REPORT_TYPES.index(type) == nil
      err = "report type not found '"+type.to_s+"''"
      LOGGER.error(err)
      raise NotFound.new(err)
    end
  end
  
end

# corresponds to 400
#
class BadRequest < Exception
  
end

# corresponds to 404
#
class NotFound < Exception
  
end

