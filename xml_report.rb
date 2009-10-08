
# = XMLReport
# 
# uses REXML to generate an XML document in DocBook article format
#
# uses Env-Variable _XMLREPORT_DTD_ to specifiy the dtd
#  
class XMLReport
  
  # create new xmlreport
  def initialize(title, author_firstname = nil, author_surname = nil)
    
    @doc = Document.new
    decl = XMLDecl.new
    @doc << decl
    type = DocType.new('article PUBLIC "-//OASIS//DTD DocBook XML V4.1//EN" "'+ENV['REPORT_DTD']+'"')
    @doc << type

    @root = Element.new("article")
    @doc << @root

    article_info = Element.new("articleinfo")
    article_info << XMLReportUtil.text_element("title", title)
    author = Element.new("author")
    author << XMLReportUtil.text_element("firstname", author_firstname)
    author << XMLReportUtil.text_element("surname", author_surname)
    article_info << author
    @root << article_info
  end
  
  # 
  # returns the root element of the document
  # call-seq:
  #   get_root_element => REXML::Element
  #
  def get_root_element
    @root
  end
  
  # adds a new section to a REXML:Element, returns the section as element
  # call-seq:
  #   add_section(element, title) => REXML::Element
  #
  def add_section(element, title)
    
    section = Element.new("section")
    section << XMLReportUtil.text_element("title", title)
    element << section
    return section
  end
  
  # adds a new paragraph to a REXML:Element, returns the paragraph as element
  # call-seq:
  #   add_paragraph( element, text ) => REXML::Element
  #
  def add_paragraph( element, text )
    
    para = XMLReportUtil.text_element("para", text)
    element << para
    return para
  end
  
  # adds a new image to a REXML:Element, returns the figure as element
  # 
  # example: <tt>add_imagefigure( section2, "Nice graph", "/images/graph1.svg", "SVG", "This graph shows..." )</tt>
  #
  # call-seq:
  #   add_imagefigure( element, title, path, filetype, caption = nil ) => REXML::Element
  #
  def add_imagefigure( element, title, path, filetype, caption = nil )
    
    figure = XMLReportUtil.attribute_element("figure", {"float" => 0})
    figure << XMLReportUtil.text_element("title", title)
    media = Element.new("mediaobject")
    image = Element.new("imageobject")
    imagedata = XMLReportUtil.attribute_element("imagedata",{"contentwidth" => "75%", "fileref" => path, "format"=>filetype})
    #imagedata = XMLReportUtil.attribute_element("imagedata",{"width" => "6in", "fileref" => path, "format"=>filetype})
    image << imagedata
    media << image
    media << XMLReportUtil.text_element("caption", caption) if caption
    figure << media
    element << figure
    return figure    
  end
  
  # adds a table to a REXML:Element, _table_values_ should be a multi-dimensional-array, returns the table as element
  # 
  # call-seq:
  #   add_table( element, title, table_values, first_row_is_table_header=true ) => REXML::Element
  #
  def add_table( element, title, table_values, first_row_is_table_header=true )
    
    raise "table_values is not mulit-dimensional-array" unless table_values && table_values.is_a?(Array) && table_values[0].is_a?(Array) 
    
    table = XMLReportUtil.attribute_element("table",{"frame" => "top", "colsep" => 0, "rowsep" => 0})
    
    table << XMLReportUtil.text_element("title", title)
    
    raise "column count 0" if table_values.at(0).size < 1 
    
    tgroup = XMLReportUtil.attribute_element("tgroup",{"cols" => table_values.at(0).size})
    
    table_body_values = table_values
    
    if first_row_is_table_header
      table_head_values = table_values[0];
      table_body_values = table_values[1..-1];
      
      thead = Element.new("thead")
      row = Element.new("row")
      table_head_values.each{ |v| row << XMLReportUtil.text_element("entry", v.to_s) }
      thead << row
      tgroup << thead
    end
    
    tbody = Element.new("tbody") 
    table_body_values.each do |r|
      row = Element.new("row")
      r.each { |v| row << XMLReportUtil.text_element("entry", v.to_s) }
      tbody << row
    end
    tgroup << tbody 
    
    table << tgroup
    element << table
    return table
  end
  
  # adds a list to a REXML:Element, returns the list as element
  # 
  # call-seq:
  #   add_list( element, list_values ) => REXML::Element
  #
  def add_list( element, list_values )
    
    list = Element.new("itemizedlist")
    
    list_values.each do |l|
      listItem = Element.new("listitem")
      add_paragraph(listItem, l.to_s)
      list << listItem
    end
    
    element << list
    return list
  end
  
  # writes xml document
  def write_to( out = $stdout )
    @doc.write(out,2)
  end

  # call-seq:
  #   self.generate_demo_xml_report => Reports::XMLReport
  #
  def self.generate_demo_xml_report

    rep = Reports::XMLReport.new("Demo report", "Fistname", "Surname")
    section1 = rep.add_section(rep.get_root_element, "First Section")
    rep.add_paragraph(section1, "some text")
    rep.add_paragraph(section1, "even more text")
    rep.add_imagefigure(section1, "Figure", "http://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/Siegel_der_Albert-Ludwigs-Universit%C3%A4t_Freiburg.svg/354px-Siegel_der_Albert-Ludwigs-Universit%C3%A4t_Freiburg.svg", "SVG", "this is the logo of freiburg university")
    section2 = rep.add_section(rep.get_root_element,"Second Section")
    rep.add_section(section2,"A Subsection")
    rep.add_section(section2,"Another Subsection")
    rep.add_section(rep.get_root_element,"Third Section")
    
    return rep
  end
  
end














  
