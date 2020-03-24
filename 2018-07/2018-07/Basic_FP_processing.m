%% Basic_FP_processing
%This is modified from what Doric sent us to calculate corrected df/f0 and
%save/plot corrected files. Not going to actually use the plotting part
%though. 
%main goal here is to batch calculate corrected df/f0's while keeping
%the DIO signal to use for FP analysis of cued app task (2019-06 at
%this point)


%% Change this directory to the folder containing your raw doric files!
directory = FP_RAW_DIRECTORY;
output_directory = FP_PROC_DIRECTORY;
files = dir(directory);
processed_files = dir(output_directory);
processed_files = [ processed_files(:).name ];
% The next function is not necessarily needed but it is just a way to
% avoid processing files already processed. Keep in mind that to be
% relevant, these functions  will work on data already selected (i.e which time range) which could be
% easily extracted from DNS or processed with something like Rick's code to
% get only 7 seconds around the tone in fear conditonning
for file = files'
  
  filename = strcat(file.name);
  splitfilename = split(filename, '.');
  splitfilename = splitfilename(1);
  
  %only process .csv files, don't process "PROCESSED" files, and don't
  %process any that already have a 'PROCESSED' version in the folder
  if isempty(strfind(filename, '.csv')) || ~isempty(strfind(splitfilename, processed_files)) || sum(strcmp(strcat('PROCESSED_',filename),{files.name}))>0
      fprintf('Detected %s as already processed, continuing...\n', filename);
      continue;
  end
  fprintf('Processing %s\n', filename);
 
  %[~,~,allData{1}] = csvread([directory,'\' filename]);  
  allData = csvread([directory,'\' filename],2,0); % 1: skip first two lines line (header); might need to skip more depeding how the file but basically the goal is to scrap the headers.
  firstLine = find(allData(:,1) > 0.1, 1); % Everything before ~100 ms is noise from the lock-in filter calculation; it sounds like this is default in the correction we get wqhen we extract DF/F0
  data = allData(firstLine:end, :); 
  
  DF_F0 = calculateDF_F0(data);
  DIO = data(:,5);

  correctedSignal = subtractReferenceAndSave(DF_F0, output_directory, filename, DIO);
end