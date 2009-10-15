
# = Reports::Predictions
#
# in case each single prediction in validation is stored, the predictions can be accessed via this class
# so far only two-class-classification is implemented
#
class Reports::Predictions
  
  attr_accessor :predicted_values, :actual_values, :compound_uris
  
  def initialize(test_dataset_uri, prediction_dataset_uri)
    OT_ACCESS.init_predictions(self, test_dataset_uri, prediction_dataset_uri)
  end
  
  def num_instances
    return @predicted_values.size
  end

  def predicted_value(instance_index)
    return @predicted_values[instance_index]
  end
  
  def actual_value(instance_index)
    return @actual_values[instance_index]
  end
  
  def compound_uri(instance_index)
    return @compound_uris[instance_index]
  end
  
  def classification_miss?(instance_index)
    return predicted_value(instance_index) < 0.5 if actual_value(instance_index) == 1
    return predicted_value(instance_index) >= 0.5 if actual_value(instance_index) == 0
    raise "illegal class value"
  end
end

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
          validation_attributes.each{ |att| a.push(v.send(att)) }
          a.push(v.get_predictions.compound_uri(i)) 
          a.push(v.get_predictions.actual_value(i).to_nice_s) 
          a.push(v.get_predictions.predicted_value(i).to_nice_s) 
          a.push(v.get_predictions.classification_miss?(i)?"X":"")
          res.push(a)
        end
      end
        
      #res = res.sort{|x,y| y[3] <=> x[3] }
      res.insert(0, validation_attributes + [ "compound_uri", "actual value", "predicted value", "missclassified" ])
      return res
  end

end
