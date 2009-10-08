
# = Reports::OTAccess
# 
# service that connects to the other ot-services
#  
class Reports::OTAccess
  
  # initialize validation object with 
  def init_validation(validation, uri)
    raise "not implemented"
  end
  
  def init_cv(validation)
    raise "not implemented"
  end
  
  def init_predictions(predictions, test_dataset_uri, prediction_dataset_uri)
    raise "not implemented"
  end
end

class Reports::WebserviceOTAccess < Reports::OTAccess
end

# = Reports::OTMockLayer
#
# does not connect to other services, provides randomly generated data
#
class Reports::OTMockLayer < Reports::OTAccess
  
  NUM_DATASETS = 1
  NUM_ALGS = 4
  NUM_FOLDS = 5
  NUM_PREDICTIONS = 30
  ALGS = ["naive-bayes", "c4.5", "svm", "knn", "lazar", "id3"]
  DATASETS = ["hamster", "mouse" , "rat", "dog", "cat", "horse", "bug", "ant", "butterfly", "rabbit", "donkey", "monkey", "dragonfly", "frog", "dragon", "dinosaur"]
  FOLDS = [1,2,3,4,5,6,7,8,9,10]
  
  def initialize
    
    super
    @algs = []
    @datasets = []
    @folds = []
    sum = NUM_DATASETS*NUM_ALGS*NUM_FOLDS
    (0..sum-1).each do |i|
      @folds[i] = FOLDS[i%NUM_FOLDS]
      @algs[i] = ALGS[(i/NUM_FOLDS)%NUM_ALGS]
      @datasets[i] = DATASETS[((i/NUM_FOLDS)/NUM_ALGS)%NUM_DATASETS]
    end
    @count = 0
  end
  
  def init_validation(validation, uri)
    
    validation.model_uri = @algs[@count]
    validation.test_dataset_uri = @datasets[@count]
    validation.prediction_dataset_uri = "bla"
    
    validation.cv_id = @count/NUM_FOLDS
    validation.fold = @folds[@count]
    
    validation.class_auc = 0.5 + validation.cv_id*0.02 + rand/3.0
    validation.class_acc = 0.5 + validation.cv_id*0.02 + rand/3.0
    validation.class_tp = 1
    validation.class_fp = 1
    validation.class_tn = 1
    validation.class_fn = 1
    
    validation.algorithm_name = @algs[@count]
    validation.training_dataset_name = @datasets[@count]
    validation.test_dataset_name = @datasets[@count]
    
    @count += 1
  end
  
  def init_cv(validation)
    
    raise "cv-id not set" unless validation.cv_id
      
    validation.CV_num_folds = NUM_FOLDS
    validation.CV_algorithm_uri = @algs[validation.cv_id.to_i * NUM_FOLDS]
    validation.CV_dataset_uri = @datasets[validation.cv_id.to_i * NUM_FOLDS]
    validation.CV_stratified = true
    validation.CV_random_seed = 1
    validation.CV_dataset_name = @datasets[validation.cv_id.to_i * NUM_FOLDS]
  end
  
  def init_predictions(predictions, test_dataset_uri, prediction_dataset_uri)
  
    p = Array.new
    c = Array.new
    u = Array.new
    (0..NUM_PREDICTIONS).each do |i|
      p.push rand
      c.push rand(2)
      u.push((i+1))
    end
    predictions.predicted_values = p
    predictions.actual_values = c
    predictions.compound_uris = u
  end

 end
