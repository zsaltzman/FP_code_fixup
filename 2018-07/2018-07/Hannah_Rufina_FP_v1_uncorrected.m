%% Hannah_Rufina_FP_v1

% built from partially completed Rufina_2019_06_FP_v4
clear;
load(getPipelineVarsFilename);

%Real folders/files
folder = FP_PROC_DIRECTORY;
outputfolder = FP_COMPILE_DIRECTORY;
medpcfile = FP_MEDPC_FILE;
outputfile = '2018-07 App MATLAB Output';

timestampfilename = FP_TIMESTAMP_FILE;
codename = 'Hannah_Rufina_FP_v1';


%set the variable letters that you're pulling
%Correct = B, Inactive = D, Receptacle = G, Reward = H, Tone on = K
%Tone off = L, Incorrect = R, Intervals used = S
variable_letters = ["B(" , "D(" , "G(" , "H(" , "K(" , "L(" , "R(" , "S("];


%Auto Import Data
C = dir([folder, '\*.csv']);
filenames = {C(:).name}.';
raw = cell(length(C),1);


for ii = 1:length(C)
    % Create the full file name and partial filename
    fullname = [folder '\' C(ii).name];
    
    % Read in the data (headers included b/c the
    raw{ii,1} = filenames(ii);
    [~,~,raw{ii,2}] = xlsread(fullname);
end

%add file names to data's first col
data = raw(:,1);


%Cycle through each row (session/day)
for row = 1:length(raw)
    
    
    %Cycle through each column/row (without grabbing headers)
    for column = 1:size(raw{row,2},2)
        
        %Grab Time col
        if strcmp(raw{row,2}{1,column}, 'Time')
            data{row,2}(:,1) = raw{row,2}(2:end,column);
        end
        
        %Grab dF/F col
        if strcmp(raw{row,2}{1,column}, 'Ca2+ Signal (DF/F0)')
            data{row,2}(:,2) = raw{row,2}(2:end,column);
        end
        
        %Grab Digital input col
        if strcmp(raw{row,2}{1,column}, 'DIO')
            data{row,2}(:,3) = raw{row,2}(2:end,column);
        end
        
    end
    
end


    
    
%% Resampling for old version of Doric that had timestamp issue

for file = 1:size(data,1)
    [resampdff, resamptime] = resample(cell2mat(data{file,2}(:,2)), cell2mat(data{file,2}(:,1)) , 121.9066);
    
    %add the resampled timestamp and dff back to data{file,3}. Converting
    %to cell since rest of code will treat it as a cell
    data{file,3}(:,1) = num2cell(resamptime);
    data{file,3}(:,2) = num2cell(resampdff);
    data{file,3}(:,3) = num2cell(NaN);
    
    % find startpulse and add zero to that ind of data{file,3}(:,3)
    
    %transfer zscored data cell (w/o latency) to tempdata as matrix
    temptimedata = cell2mat(data{file,2}(:,1:3));
    
    %find the start pulse (first 0 in DIO) from pre-resampled data
    starttimeindex = find(temptimedata(:,3)<1,1,'first');
    starttime = temptimedata(starttimeindex,1);
    
    %find index of closest timestamp to first 0
    [~,closeststarttimeind] = min(abs(cell2mat(data{file,3}(:,1))-starttime));
    
    %add 0 to that row, col 3
    data{file,3}{closeststarttimeind,3} = 0;
    
    %clear out data{:,2} since it's been copied to data{:,3} for zscoring
    %did this to speed up code. Remove this if you need to spot check data
    %data{file,2} = [];
    
    clear temptimedata
    
end


%% Save doric data load point interim for faster running

%saved way too big of a file and got stuck
% save([outputfolder '\' outputfile '_' codename '_doricinterim' date '.mat'],'-v7.3')


%% Read in MedPC Data
%Don't have to iterate this bc everything is the the excel file
%% Import the data
[~, ~, medrawpresort] = xlsread(medpcfile);
%only imported Cued and CuedTO

%cut off column headings and sort by animal ID, ascending order
%important! make sure medpc2excel imported by ascending date
%order
medheadsum = medrawpresort(1,1:16);
medheader = medrawpresort(1,:);
medrawpresort = medrawpresort(2:end,:);

sortingmatrix = zeros(size(medrawpresort,1),1);
for row = 1:size(medrawpresort,1)
    sortingmatrix(row,1) = str2num(medrawpresort{row,1}(3:4));
end

%sort mouse number then sort medrawpresort by sortidx
[~,sortidx] = sort(sortingmatrix);

medraw = medrawpresort(sortidx,:);
clear medrawpresort;

%cycle through each mouse
for row = 1:size(medraw,1)
    
    meddata = cell(1,8);
    
    for variable=1:8
        %% Pull the variables from raw into their own rows of cell raw1
        %Find all the days that are the given variable
        array_header = strfind(medheader,variable_letters{variable});
        
        %find the first non-empty cell and set that index to TO
        first = find(~cellfun(@isempty,array_header),1);
        last = find(~cellfun(@isempty,array_header),1, 'last');
        
        raw1 = medraw(row,first:last);
        
        raw1(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw1)) = {''};
        
        %Replace non-numeric cells with NaN
        R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw1); % Find non-numeric cells
        raw1(R) = {NaN}; % Replace non-numeric cells
        
        %Create output variable
        meddata{1,variable}= reshape([raw1{:}],size(raw1));
               
        medsum=medraw(row,1:16);
             
        %% Clear temporary variables
        clearvars raw1 R ;
        
    end
    
    
    %% Calculate latency (cue on to Reward(First Proper NP of trial), col 9) and training day mean latency (col 10), and concat to data. Row = training day
    
    %Changed ProperANP to rewards from previous version because ProperANPs now
    %colllect any extra Proper ANPs made (within the 2 sec the tone can still play after the first), not just first one
    
    %this next line should be the size of meddata,
    %
    latency = cell(size(meddata,1),2);
    %probably don't need this loop since it's just 1 row per file. If
    %was looping like before (within a mouse) it'd matter
    for datarow=1:size(meddata,1)
        
        
        for Reward=1:size(meddata{datarow,4},2)
            toneid = find(meddata{datarow,4}(Reward)>meddata{datarow,5},1, 'last');
            if meddata{datarow,4}(Reward) - meddata{datarow,5}(toneid) <= 10
                latency{datarow,1}(Reward) = meddata{datarow,4}(Reward)- meddata{datarow,5}(toneid);
            end
            
        end
        %average latency
        latency{datarow,2} = cellfun(@mean,latency(datarow));
    end
    
    
    %add latency to data cell
    meddata = [meddata latency];
    
    clear datarow toneid Reward latency
    
    %% Reward latency
    rewlatency = cell(size(meddata,1),2);
    
    %probably don't need this loop since it's just 1 row per file. If
    %was looping like before (within a mouse) it'd matter
    for datarow=1:size(meddata,1)
        
        
        for Reward=1:size(meddata{datarow,4},2)
            
            recepidx = find(meddata{datarow,4}(Reward)<meddata{datarow,3},1);
            if meddata{datarow,3}(recepidx)-meddata{datarow,4}(Reward)<10
                rewlatency{datarow,1}(Reward) = meddata{datarow,3}(recepidx) - meddata{datarow,4}(Reward);
            end
        end
        
        %calculate mean of all rewlatencies
        rewlatency{datarow,2} = cellfun(@mean,rewlatency(datarow));
        
        
    end
    
    %add latency to data cell
    meddata = [meddata rewlatency];
    
    clear datarow  recepidx  Reward rewlatency
    %% Add medsum, meddata (including latencies) to overall data
    %Need to make this add to data row instead
    
    
    %medheader and med sum
    medsum = {[medheadsum;medsum]};
    
    %add med sum and meddata to data cell
    data{row,4} = [medsum meddata];
    
    
    %% clear
    clear meddata variable
    
end

%clear for memory
clear raw_mouse medraw

%% Loop through all data files
%scrub, add timestamp latency, zscore
for file = 1:size(data,1)
    
    
    %% Scrub weird spikes
    %turn weird spikes to NaN
    for datarow=1:size(data{file,3},1)
        if data{file,3}{datarow,2} < -100 || data{file,3}{datarow,2} > 100
            data{file,3}{datarow,2} = NaN;
        end
    end
    
    
    %time stamp latency into 4th column of data{file,2}
    for datarow = 2:size(data{file,3},1)
        data{file,3}{datarow,4} = data{file,3}{datarow,1}-data{file,3}{datarow-1,1};
    end
    
    
    %% Make zscore cell entry (file,3)
    dffcolumn = cell2mat(data{file,3}(:,2));
    zdff = nanzscore(dffcolumn);
    
    data{file,3}(:,2) = num2cell(zdff);
    %improved code above
    %     for row = 1:size(zdff,1)
    %         data{file,3}{row,2} = zdff(row);
    %     end
    %
    
    %% Trim to startpulse
    
    %transfer zscored data cell (w/o latency) to tempdata as matrix
    clear tempdata
    tempdata = cell2mat(data{file,3}(:,1:3));
    
    %find the start pulse (first 0 in DIO), align t = 0 to that, and trim
    %tempdata to remove pre-start pulse rows
    starttimeindex = find(tempdata(:,3)<1,1,'first');
    starttime = tempdata(starttimeindex,1);
    tempdata(:,1) = tempdata(:,1)-starttime;
    tempdata = tempdata(starttimeindex:end,:);
    
    
    %% Identify actions, put them in col 4 of tempdata, put tempdata into col 5 of data
    
    %add NaN to col 4
    blankcol = NaN(size(tempdata,1),1);
    tempdata = [tempdata blankcol];
    
    %action = place in summary cell | place in timestamp col| action ID
    %correct = 9 | 2 | 1
    %extracorrect = 9 | 2 | 5
    %tone = 14 | 6| 2
    %incorrect = 10 | 8 |  3
    %incorrect not leading to TO (within 5 sec of another incorrect) = 7
    %receptacle 13 | 4| 4
    %inactive 11 | 3 |  6
    
    %medactiontimecol = column in data{file,4} for given action
    %note, these are +1 what they were assigned earlier bc sum col is first
    medactiontimecol = [2 6 8 4 3];
    
    %index in summary to reference, to get number of actions
    medsumaction = [9 14 10 13 11];
    
    %key for actions
    aidkey = [1 2 3 4 6];
    
    %assign ID for actions
    for variable = 1:5
        for action = 1:data{file,4}{1,1}{2,medsumaction(variable)}
            timestamp = data{file,4}{1,medactiontimecol(variable)}(action);
            
            %find index of closest timestamp
            [~,doricind] = min(abs(tempdata(:,1)-timestamp));
            
            %add aidkey to column 4
            tempdata(doricind,4) = aidkey(variable);
            
            %Change a doubletapped correct to extra correct
            if variable == 1
                [~,testextraind] = min(abs(tempdata(:,1)-(timestamp-2.3)));
                
                if  any(tempdata(testextraind:doricind-1,4)==1)
                    tempdata(doricind,4) = 5;
                end
            end
            
            %Change a non-TO yielding incorrect to 7
            if variable == 3
                [~,testextraimp] = min(abs(tempdata(:,1)-(timestamp-5.08)));
                
                if  any(tempdata(testextraimp:doricind-1,4)==3)
                    tempdata(doricind,4) = 7;
                end
            end
            
            %Weeding out close together rec entries. Not sure how stringent I should be but
            %I'll do the same as incorrect (none 5 sec before) just to be
            %sure. Extra rec = 8
            
            %also going to divide by rec that follows a reward and those
            %that are random = 9
            if variable == 4
                [~,testextrarec] = min(abs(tempdata(:,1)-(timestamp-5.08)));
                
                if  any(tempdata(testextrarec:doricind-1,4)==4) || any(tempdata(testextrarec:doricind-1,4)==9)
                    tempdata(doricind,4) = 8;
                    
                elseif ~any(tempdata(testextrarec:doricind-1,4)==1)
                    tempdata(doricind,4) = 9;
                    
                end
                
                
                
            end
            
            %need to take out close together inactives
            
        end
    end
    
    
    %put tempdata into data
    data{file,5} = tempdata;
    
    %clear zscore col bc no longer needed after data{file,5} made
    data{file,3} = [];
    
    %% Testing AID
    
    %Find where ~nans are (when you don't catch it at tempdata stage)
    % test = data{file,5}(~isnan(data{file,5}(:,4)),:);
    
    
    
    %mismatch
    %     %Use these lines to test mismatch between when doric and medpc say an
    %     %action happened. I looked through several and it seems like the mismatch
    %     %occurs do to rounding/difference in timestamp latency between medpc/doric.
    %     %Medpc will say the action started one dorictimestamp before it did in
    %     %doric. Not a big deal, just a rounding error and so long as we're goign to
    %     %make everything timestamp driven and reference medpc's recorded timestamps, we're good.
    %           %Note:For some reason, MedPC code doesn't send a TTL to doric
    %           when there's an incorrect that doesn't result in TO. There will
    %           be mismatch bc of that
    %
    %     test = tempdata(~isnan(tempdata(:,4)),:);
    %     mismatch = test(test(:,3)>0,:);
    %     [~,misind] = min(abs(tempdata(:,1)-mismatch(1,1))); %change the mismatch row to look at other instances
    %     missi = tempdata(misind-5:misind+5,:)
    
    
    
end

clear tempdata
%% Search through action number column and constuct arrays with zdF/F0

%action = place in summary cell | place in timestamp col| action ID
%correct =  1
%extracorrect = 5
%tone = 2
%incorrect = 3
%incorrect not leading to TO (within 5 sec of another incorrect) = 7
%receptacle = 4
%inactive = 6


%create a variable to let me know how many actions were cut off due to
%different restrictions such as not enough time, etc

%initialize rawtogether
rawtogether = cell(size(data,1),2);

for file = 1:size(data,1)
    
    %this file was cut short
    if strcmp(filenames{file},'PROCESSED_HB06_Timeout_Day_13_3.csv')
        cutoff = 1110;
    else
        cutoff = 1789.5;
    end
    
    % twenty seconds before the end of the file
    % cutoff = data{file, 5}(length(data{file, 5}(:, 1)), 1) - 10.5;
    
    
    %preallocate arrays and counters
    correct = zeros(1832,0);
    correctcounter = 0;
    
    tone = zeros(1832,0);
    tonecounter = 0;
    tonehit = zeros(1832,0);
    tonehitcounter =0;
    tonemiss = zeros(1832,0);
    tonemisscounter =0;
    
    incorrect = zeros(1832,0);
    incorrectcounter = 0;
    
    receptacle = zeros(1832,0);
    receptaclecounter = 0;
    
    randrec = zeros(1832,0);
    randreccounter = 0;
    
    
    inactive = zeros(1832,0);
    inactivecounter = 0;
    
    %rawtogether is where I'm pulling everything from 5 sec before tone to 5
    %sec after rec (or after NP if rec entry didn't happen within 5 sec
    %after NP)
    
    
    
    
    %latency arrays
    ttp_list = zeros(0);
    ptr_list = zeros(0);
    
    
    
    
    %find all of the inidices of actions (not NaNs in aid cols)
    [actionind] = find(~isnan(data{file,5}(:,4)));
    
    %     %testing
    %     testingAID = data{file,5}(actionind,[1 4]);
    %     testingAID = [actionind testingAID];
    
    %go through all actions in a given file
    for action=1:size(actionind,1)
        
        %make sure the the action isn't too close to start or end of
        %session
        if data{file,5}(actionind(action),1) > 5.1 && data{file,5}(actionind(action),1) <  cutoff
            
            %correct (reward delivery prop only)
            if data{file,5}(actionind(action),4) == 1
                correctcounter = correctcounter +1;
                correct(1:end,correctcounter) = data{file,5}(actionind(action)-610:actionind(action)+1221,2);
                
                %rawtogether
                
                %find the tone that came before this correct NP
                lasttone = find(data{file,5}(1:actionind(action),4)==2, 1,'last');
                
                %find the rec that came immediately after this correct NP
                nextrec = find(data{file,5}(actionind(action):end,4)==4, 1,'first')+actionind(action)-1;
                
                if data{file,5}(nextrec,1) - data{file,5}(actionind(action),1) <= 5.008 %change from 5.08 to 5.008
                    %if there's a rec after correct np within 5 sec, take 5 sec
                    %after that
                    
                    %grab tone - 5 sec : rec + 5 sec
                    rawtogether{file,1}{1,correctcounter} = data{file,5}(lasttone-610:nextrec+610,[1 2 4]);
                    
                    %grab just tone - 5 sec : poke + 5 sec
                    rawtogether{file,1}{2,correctcounter} = data{file,5}(lasttone-610:actionind(action)+610,[1 2 4]);
                    
                    %grab latency from tone to poke
                    rawtogether{file,1}{3,correctcounter} = rawtogether{file,1}{2,correctcounter}(end-610,1)-rawtogether{file,1}{2,correctcounter}(611,1);
                    
                    %grab rew latency (poke to rec entry)
                    rawtogether{file,1}{4,correctcounter} = data{file,5}(nextrec,1) - data{file,5}(actionind(action),1);
                    
                    %if there was no rec entry 5 sec after correct, don't take the
                    %event
                        %note: this means that there will be an empty
                        %column for those rewards that don't meet this
                        %requirement
                    
                end
                
                %tone
            elseif data{file,5}(actionind(action),4) == 2
                %fancy way to do it is here, but just doing 10 sec by 1221+2 extra cells jic
                %[~,plus10ind] = min(abs(data{file,5}(actionind(action):end,1)-(data{file,5}(actionind(action),1)+10)));
                tonecounter = tonecounter +1;
                tone(1:end, tonecounter) = data{file,5}(actionind(action)-610:actionind(action)+1221,2);
                
                
                
                %tonehit
                if any(ismember(data{file,5}(actionind(action):actionind(action)+1223,4),1)) == 1
                    tonehitcounter = tonehitcounter +1;
                    tonehit(1:end, tonehitcounter) = data{file,5}(actionind(action)-610:actionind(action)+1221,2);
                    
                    %tonemiss
                else
                    tonemisscounter = tonemisscounter + 1;
                    tonemiss(1:end, tonemisscounter) = data{file,5}(actionind(action)-610:actionind(action)+1221,2);
                end
                
                
                %tone to correct latency
                %*come back to this
                
                %incorrect
            elseif data{file,5}(actionind(action),4) == 3
                incorrectcounter = incorrectcounter + 1;
                incorrect(1:end,incorrectcounter) = data{file,5}(actionind(action)-610:actionind(action)+1221,2);
                
                %receptacle
            elseif data{file,5}(actionind(action),4) == 4
                receptaclecounter = receptaclecounter + 1;
                receptacle(1:end,receptaclecounter) = data{file,5}(actionind(action)-610:actionind(action)+1221,2);
                
                %randrec (rec entry not following reward)
            elseif data{file,5}(actionind(action),4) == 9
                randreccounter = randreccounter + 1;
                randrec(1:end,randreccounter) = data{file,5}(actionind(action)-610:actionind(action)+1221,2);
                
                
                
                %inactive
            elseif data{file,5}(actionind(action),4) == 6
                inactivecounter = inactivecounter + 1;
                inactive(1:end,inactivecounter) = data{file,5}(actionind(action)-610:actionind(action)+1221,2);
                
                
            end
            
            
        else
            %cutoff variable
            
        end
    end
    
    %action counter
    actioncounter = {'correct' 'tone' 'incorrect' 'receptacle' 'randrec' 'tonehit' 'tonemiss' 'inactive'; ...
        correctcounter tonecounter incorrectcounter receptaclecounter randreccounter tonehitcounter tonemisscounter inactivecounter};
    
    %only take means if not an empty cell
    if ~cellfun(@isempty,rawtogether(file,1))
        rawtogether{file,2} = mean(cell2mat(rawtogether{file,1}(3,:)));
        rawtogether{file,3} = mean(cell2mat(rawtogether{file,1}(4,:)));
    end
    
    %write all the zdffdata into an excel sheet for an individual day, assign
    %% Write the tempdata
    %this is the way data was written out when wanting to align to
    %inidividual actions. Now also adding a variable "together"
    outputname = [outputfolder '\MATLAB_' data{file,1}{1}(11:end-6) '.xlsx'];

%     Comment since don't need outputs right now
    
    xlswrite(outputname, actioncounter, 'counter');
    
    if correct ~= 0
        xlswrite(outputname, correct, 'correct');
    end
    
    if tone ~= 0
        xlswrite(outputname, tone, 'tone');
    end
    
    if incorrect ~= 0
        xlswrite(outputname, incorrect, 'incorrect');
    end
    
    if receptacle ~= 0
        xlswrite(outputname, receptacle, 'receptacle');
    end
    
    if randrec ~= 0
        xlswrite(outputname, randrec, 'randrec');
    end
    
    if tonehit ~= 0
        xlswrite(outputname, tonehit, 'tonehit');
    end
    
    if tonemiss ~= 0
        xlswrite(outputname, tonemiss, 'tonemiss');
    end
    
    if inactive ~= 0
        xlswrite(outputname, inactive, 'inactive');
    end
    
%     
    
    %it to the data cell
    
    %then clear the temp zdffdata arrays
    
end

%% Timestamp file
%added from Hannah 2018-07 (shou
%make a timestamp file from the first file's first correct nosepoke
file = 1;

%find the ind of the first correct np
[timeind] = find(data{file,5}(:,4)==1,1,'first');

%correct (reward delivery prop only)

timestampfile = data{file,5}(timeind-610:timeind+1221,1)-data{file,5}(timeind,1);


xlswrite(timestampfilename,timestampfile)




%% Save data in file

%save all variables together
% save([outputfolder '\' outputfile '.mat']);

%save just rawtogether and names
save([outputfolder '\' outputfile 'rawandnamesonly' date '.mat'], 'rawtogether', 'filenames', '-v7.3');

%% Print code version text file

%print the version of the code used
fileID = fopen([outputfolder '\codeused.txt'],'w');
fprintf(fileID, codename);

