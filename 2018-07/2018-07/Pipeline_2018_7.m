clear; 

% IMPORTANT NOTE: Before running this code please make sure that all the
% pipeline scripts are in the same directory, otherwise this isn't
% guaranteed to run!

% Change these names to the locations of the relevant files on your machine
FP_RAW_DIRECTORY = 'D:\Picciotto Lab Stuff\FP Code Fixup\2018-07\2018-07\raw';
FP_PROC_DIRECTORY = 'D:\Picciotto Lab Stuff\FP Code Fixup\2018-07\2018-07\Outputs\generated processed';
FP_COMPILE_DIRECTORY = 'D:\Picciotto Lab Stuff\FP Code Fixup\2018-07\2018-07\Outputs\generated MATLAB';
FP_MEDPC_FILE = 'D:\Picciotto Lab Stuff\FP Code Fixup\2018-07\2018-07\2018-07 MedPC Full.xlsx';
FP_TIMESTAMP_FILE = 'D:\Picciotto Lab Stuff\FP Code Fixup\2018-07\2018-07\pipeline_2018_7 timestamps.xlsx';

FP_MEAN_SEM_DIRECTORY = 'D:\Picciotto Lab Stuff\FP Code Fixup\2018-07\2018-07\Outputs\generated day graphs';
FP_SUMMARY_DIRECTORY = 'D:\Picciotto Lab Stuff\FP Code Fixup\2018-07\2018-07\Outputs\generated summary graphs';
FP_SUMMARY_TP_DIRECTORY = 'D:\Picciotto Lab Stuff\FP Code Fixup\2018-07\2018-07\Outputs\generated summary_tone_poke graphs';

FP_INDIVIDUAL_DAY_DATA_FILENAME = [ FP_MEAN_SEM_DIRECTORY '\individual_day_graph_data.mat' ];

% This should be the root folder of your study and this should be the ONLY
% Matlab variable file in the root directory
save(getPipelineVarsFilename); 

% Uses subtractReferenceAndSave and calculateDF_F0
% Basic_FP_processing

% Hannah_Rufina_FP_v1_uncorrected 

% rick_mean_SEM_calc_indiv_plots_v3

rick_HanRuf_actions_heatmaps_all_phases_v4_1_pub

rick_tone_poke_rec_heatmaps_by_mouse_v2_1