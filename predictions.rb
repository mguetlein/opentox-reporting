

module Reports::PredictionUtil

  # creates an Array for a table
  # * first row: header values
  # * other rows: the prediction values
  # additional attribute values of the validation that should be added to the table can be defined via validation_attributes
  # 
  # call-seq:
  #   predictions_to_array(validation_set, validation_attributes=[]) => Array
  #
  def self.predictions_to_array(validation_set, validation_attributes=[])
  
      res = []
      
      validation_set.validations.each do |v|
        (0..v.get_predictions.num_instances-1).each do |i|
          a = []
          validation_attributes.each{ |att| a.push(v.send(att).to_s) }
          a.push(v.get_predictions.compound(i)[0,65]) #.gsub(/[-(),=]/, '')[0,10])
          a.push(v.get_predictions.actual_value(i).to_nice_s) 
          a.push(v.get_predictions.predicted_value(i).to_nice_s) 
          a.push(v.get_predictions.classification_miss?(i)?"X":"")
          a.push(v.get_predictions.confidence_value(i).to_nice_s) 
          res.push(a)
        end
      end
        
      #res = res.sort{|x,y| y[3] <=> x[3] }
      res.insert(0, validation_attributes + [ "compound", "actual value", "predicted value", "missclassified", "confidence value" ])
      #puts res.collect{|c| c.inspect}.join("\n")
      
      return res
  end

end
