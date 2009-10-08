
load "environment.rb"

  ################################################

#system("rm -rf /home/martin/tmp/reports/*")
rep = Reports::ReportService.new

puts rep.get_all_reports("crossvalidation")

#puts rep.parse_type_and_id("file://home/martin/tmp/reports/crossvalidation/1")
#puts rep.get_all_reports("crossvalidation")
#rep.delete_report("crossvalidation", 1)
#puts rep.get_all_reports("crossvalidation")

#puts rep.get_report_types
#puts rep.get_all_reports("validation")

#puts rep.create_report("crossvalidation", ["validation_uri_1","validation_uri_2", "validation_uri_3", "validation_uri_4", "validation_uri_5"])
#puts rep.get_report("crossvalidation", "1", "html")

#puts rep.create_report("validation", ["validation_uri_1"])
#puts rep.get_report("validation", "1", "html")

#puts rep.create_report("algorithm_comparison", ["validation_uri"] * (Reports::OTMockLayer::NUM_DATASETS * Reports::OTMockLayer::NUM_ALGS * Reports::OTMockLayer::NUM_FOLDS))
#puts rep.get_report("algorithm_comparison", "1", "html")


################### plot_util #############################################

#demo_roc_plot
#demo_ranking_plot
#demo_bar_plot

################### xml_report ############################################

#rep = Reports::XMLReport::generate_demo_xml_report
#rep.write_to()

################### report_generator #######################################

#demo_report_2

################### validations #######################################

#set = demo_validation_set_3
#set = set.merge(["Algorithm","Dataset"],["Fold"],[])
#puts set.rank_and_plot_ranking("Algorithm", "Dataset", "AUC");

################### standard_reports #######################################

#set = demo_validation_set_2
#set = set.copy( nil, { "Algorithm"=>"IBk-Tanimoto" })
#puts set.to_s_table
#single_algorithm_single_dataset(set)


#set = demo_validation_set_2
#puts set.to_s_table
#multiple_algorithms_single_dataset(set)

#################################################################################

#puts create_random_validation_as_xml
  


