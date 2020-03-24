%% rick_HanRuf_actions_heatmaps_all_phases_v4_pub

%4_1: collapse over different days, based on incorrect
%v4: added 10 rew lines and collapse graph for pub incorrect
%v3: Adding back in mean/sem compiling for prism, also changed to jet
%v2: changing labeling+numbering for publication.

% built from rick_2019_06_means_heatmaps_all_phases_v3
%to merge 2018-07 in with it


%v3 make sure the arrays get cleared
%v2 making heatmaps that are in line with tone_to_poke maps

%Removed this SEM stuff so heatnumbers just becomes the variable
%Note: this has remnants of from when I was plotting mean data in Prism.
%The action arrays are actually twice as large as number of days, with each
%first column being mean and second column being the SEM. They heatmaps use
%indexing that accounts for this when making heatnumbers variable

%Copy of heatmaps_sep_by_phase_Ribicoff
%mod'd to put all phases together


%% clear
clear

exp = '2018-07';
% exp = '2019-06';

codename = 'rick_actions_heatmaps_all_phases_v4_1_pub';
%% Set folder/files


if strcmp(exp,'2019-06')
    
    folder = 'C:\Users\User\Google Drive\2019-06 NBM-BLA + GACh FP\Doric\Processed\2019-06 App MATLAB\Individual Day Graphs' ;
    
    load([folder '\2019-06 App MATLAB graph data 25-Dec-2019_rick_mean_SEM..._v3.mat'])
    
    
    outputfolder = 'C:\Users\User\Google Drive\2019-06 NBM-BLA + GACh FP\Doric\Processed\2019-06 App MATLAB\Summary Graphs by action';
    outputfile = 'MATLAB means+sem for prism';
    timestampfile = 'C:\Users\User\Google Drive\2019-06 NBM-BLA + GACh FP\timestamp.xlsx';
    
    skips = ["827_Timeout_Day_06"; "820_Timeout_Day_06";"814_Timeout_Day_01"; "814_Timeout_Day_07"; "813_Timeout_Day_12"];
    
    
elseif strcmp(exp,'2018-07')
    
    folder = 'C:\Users\User\Google Drive\2018-07 BLA Fiber Pho\Doric\Processed\2018-07 App MATLAB\Individual Day Graphs' ;
    
    load([folder '\2018-07 App MATLAB graph data 23-Dec-2019_rick_mean_SEM..._v3.mat'])
    
    outputfolder = 'C:\Users\User\Google Drive\2018-07 BLA Fiber Pho\Doric\Processed\2018-07 App MATLAB\Summary Graphs';
    outputfile = '2018-07 MATLAB means+sem for prism';
    timestampfile = 'C:\Users\User\Google Drive\2018-07 BLA Fiber Pho\timestamp.xlsx';
    
    skips = ["HB03_Timeout_Day_12"; "HB04_Timeout_Day_11"; "HB04_Timeout_Day_13"; "HB05_Timeout_Day_09"; "HB06_Timeout_Day_09";  "HB06_Timeout_Day_11"; "HB08_Timeout_Day_12"];
    
end




%Groups
NBM_BLA = [810 811 812 819];
BLA_GACh = [813 814 820 827];
BLA_GCaMP = [3 4 6];

%file to skip

%can bring back in 813 TO 12 once I cut off that last 5 mins
%added 814 TO 01 because there's no reward with receptacle following within
%5 sec, this way will keep consistent with tone_poke_rec plots


variables = ["correct" "tone" "incorrect" "receptacle" "randrec" "tonehit" "tonemiss" "inactive"];
prism_variables = ["p_correct" "p_tone" "p_incorrect" "p_receptacle" "p_randrec" "p_tonehit" "p_tonemiss" "p_inactive"];

%import timestamp
time = xlsread(timestampfile);
graphtime = time;

%initialize
data_mouse_ID = zeros(size(datanames,1),1);


if strcmp(exp,'2019-06')
    
    %prep for cut down data to just one mouse
    
    for ii = 1:size(datanames,1)
        data_mouse_ID(ii) = str2double(datanames{ii}{1}(8:10));
    end
    
    all_mouse_ID= unique(data_mouse_ID);
    
    
    
    %for drawing white line
    rew_threshold = ["813_Timeout_Day_20"; "814_Timeout_Day_17"; "820_Timeout_Day_19"; "827_Timeout_Day_18"];
    
    %for grabbing specific days for collapsing mice
    TO_10_rew = ["813_Timeout_Day_10"; "814_Timeout_Day_10"; "820_Timeout_Day_10"; "827_Timeout_Day_08"];
    
    %picked ext by picking last ext day that had at least four trials with
    %tone-np-rec
    %for grabbing specific days for collapsing mice
    Ext_Day = ["813_ZExtinction_Day_03"; "814_ZExtinction_Day_04"; "820_ZExtinction_Day_01"; "827_ZExtinction_Day_02"];
    
    
elseif strcmp(exp,'2018-07')
    %prep for cut down data to just one mouse
    
    for ii = 1:size(datanames,1)
        data_mouse_ID(ii) = str2double(datanames{ii}{1}(11));
    end
    
    all_mouse_ID= unique(data_mouse_ID);
    
    
    %for drawing white line
    rew_threshold = ["3_Timeout_Day_08"; "4_Timeout_Day_08"; "6_Timeout_Day_13"];
    
    Ext_Day = ["3_ZZExt_Day_1"; "4_ZZExt_Day_1"; "6_ZZExt_Day_2"];
end

%set for loop num

if strcmp(exp,'2019-06')
    %skip mouse 819 (NBM-BLA)
    nummer = [1 2 4 5];
    
elseif strcmp(exp,'2018-07')
    
    nummer = [1 2 4];
    
end


%% cut down data to just one mouse
for num = nummer
    
    %Define mouse_ID number for the run of the for loop
    mouse_ID = all_mouse_ID(num);
    
    %What indicator is it?
    if any(mouse_ID == BLA_GACh)
        indicator = 'BLA GACh';
        GAChnum=find(BLA_GACh==mouse_ID);
        
    elseif any(mouse_ID == BLA_GCaMP)
        indicator = 'BLA GCaMP';
        BLAGCaMP_num=find(BLA_GCaMP==mouse_ID);
        
        
    end
    
    %Cut down raw to just current mouse
    %Index all rows with mouse_ID and select those rows from graphdata
    %     mousedata = graphdata((data_mouse_ID(:,1) == mouse_ID),:);
    mousemean = graphmean((data_mouse_ID(:,1) == mouse_ID),:);
    mousesem = graphsem((data_mouse_ID(:,1) == mouse_ID),:);
    mousenames = datanames((data_mouse_ID(:,1) == mouse_ID),:)';
    
    
    
    
    %making trimmed___ be equal to mouse___ to not have to change as much
    %coe
    %trim to training phase
    %     trimmeddata = mousedata;
    trimmedmean = mousemean;
    trimmedsem = mousesem;
    trimmednames = mousenames;
    
    
    
    
    
    
    
    %% Make arrays for each mouse, across days
    
    %variables = ["correct" "tone" "incorrect" "receptacle" "randrec" "tonehit" "tonemiss" "inactive"];
    
    %need to check the flow of the loops,
    
    %initialize arrays
    %     correct = NaN(size(trimmedmean{1,1},1), size(trimmedmean,1)*2);
    %     tone = correct;
    %     incorrect  = correct;
    %     receptacle = correct;
    %     randrec = correct;
    %     tonehit = correct;
    %     tonemiss = correct;
    %     inactive = correct;
    
    
    clear correct tone incorrect receptacle randrec tonehit tonemiss inactive day_align_filenames
    
    %        for action = [1 3 4 6]
    for action = 1:size(trimmedmean,2)
        
        %use day_counter to prevent black bar when skipping days
        day_counter = 0;
        
        for file = 1:size(trimmedmean,1)
            
            
            %skip shitters
            if any(strcmp(trimmednames{file}{1}(8:end-5),skips))
                
                
                continue
                
            else
                
                day_counter = day_counter+1;
                
                if action == 1
                    %determine the day of mice
                    day_align_filenames{day_counter,1} = trimmednames{1,file}{1};
                    p_day_align_filenames{day_counter*2-1,1} = trimmednames{1,file}{1};
                    p_day_align_filenames{day_counter*2,1} = [];
                end
                
                %if that action didn't happen that day, just put NaN's
                if isempty(trimmedmean{file,action})
                    
                    
                    eval([variables{action}, '(:,day_counter) = NaN(1832,1);']);
                    eval([prism_variables{action}, '(:,day_counter*2-1) =  NaN(1832,1);']);
                    eval([prism_variables{action}, '(:,day_counter*2) = NaN(1832,1);']);
                    
                    
                    %put the meandata in the action variable
                else
                    %Fill in mean
                    
                    %e.g. correct(:,file) = ...
                    eval([variables{action}, '(:,day_counter) = trimmedmean{file,action};']);
                    
                    
                    %fill in mean/sem for prism variables
                    %doing this with day_counter like above instead of
                    %NaNs because I'll transfer over row titles too
                    %instead of bulk copying (with blanks created by
                    %NaNs) like before
                    eval([prism_variables{action}, '(:,day_counter*2-1) = trimmedmean{file,action};']);
                    
                    %fill with NaNs if SEM is all 0 (meaning only one
                    %trial)
                    if sum(trimmedsem{file,action})==0
                        eval([prism_variables{action}, '(:,day_counter*2) = NaN(1832,1);']);
                    else
                        
                        %fill in SEM
                        eval([prism_variables{action}, '(:,day_counter*2) = trimmedsem{file,action};']);
                    end
                    
                    
                end
                
            end
            
        end
        
    end
    
    %% Find start day of phases and threshold days
    
    %XXX Note: setting day_align to incorrect only here, will need to
    %iterate later if I'm going to do all variables
    day_align = incorrect;
    
    %Find all the days that are Timeout
    timeout_test = strfind(lower(day_align_filenames),lower('Timeout'));
    
    %find the first non-empty cell and set that index to TO
    TO = find(~cellfun(@isempty,timeout_test),1);
    
    TO_Last_day = find(~cellfun(@isempty,timeout_test),1,'last');
    
    if strcmp(exp,'2019-06')
        %Find all the days that are Ext
        Ext_test = strfind(day_align_filenames,'ZExtinction');
        
    elseif strcmp(exp,'2018-07')
        Ext_test = strfind(day_align_filenames,'ZZExt');
        
    end
    
    
    %find the first non-empty cell and set that index to TO
    Ext = find(~cellfun(@isempty,Ext_test),1);
    
    %Find the rew_thresh day
    %indexing by the num of GACh mouse, into the rew_threshold array that
    %has the full names for the threshold days, similar to above but
    %looking for a specific day, not just one
    
    
    % for GCaMP mice
    
    if mouse_ID == 3 || mouse_ID ==4 || mouse_ID ==6
        
        %rew thresh day
        rew_thresh_test = strfind(day_align_filenames,rew_threshold(BLAGCaMP_num));
        
        rew_thresh_day = find(~cellfun(@isempty,rew_thresh_test),1);
        
        rew_thresh_all_mice(:,BLAGCaMP_num) = day_align(:,rew_thresh_day );
        
        %ext day
        Ext_Day_test = strfind(day_align_filenames,Ext_Day(BLAGCaMP_num));
        
        Ext_Day_day = find(~cellfun(@isempty,Ext_Day_test),1);
        
        Ext_Day_day_all_mice(:,BLAGCaMP_num) = day_align(:,Ext_Day_day );
        
        
        %    Cued_day_1
        Cued_day_1_test = strfind(lower(day_align_filenames),lower([num2str(BLA_GCaMP(BLAGCaMP_num)) '_Cued_Day_1']));
        
        Cued_day_1_day = find(~cellfun(@isempty,Cued_day_1_test),1);
        
        Cued_day_1_all_mice(:,BLAGCaMP_num) = day_align(:,Cued_day_1_day);
        
        %    Cued_day_4
        Cued_day_4_test = strfind(lower(day_align_filenames),lower([num2str(BLA_GCaMP(BLAGCaMP_num)) '_Cued_day_4']));
        
        Cued_day_4_day = find(~cellfun(@isempty,Cued_day_4_test),1);
        
        Cued_day_4_all_mice(:,BLAGCaMP_num) = day_align(:,Cued_day_4_day);
        
         %TO_day_01
        
        TO_day_01_test = strfind(lower(day_align_filenames),lower([num2str(BLA_GCaMP(BLAGCaMP_num)) '_Timeout_Day_01']));
        
        TO_day_01_day = find(~cellfun(@isempty,TO_day_01_test),1);
        
        if ~isempty(TO_day_01_day)
        TO_day_01_day_all_mice(:,BLAGCaMP_num) = day_align(:,TO_day_01_day);
        end
        
        %TO_day_03
        
        TO_day_03_test = strfind(lower(day_align_filenames),lower([num2str(BLA_GCaMP(BLAGCaMP_num)) '_Timeout_Day_03']));
        
        TO_day_03_day = find(~cellfun(@isempty,TO_day_03_test),1);
        
        TO_day_03_day_all_mice(:,BLAGCaMP_num) = day_align(:,TO_day_03_day);
        
        
    end
    
    
    if any(mouse_ID == BLA_GACh)
        rew_thresh_test = strfind(day_align_filenames,rew_threshold(GAChnum));
        
        rew_thresh_day = find(~cellfun(@isempty,rew_thresh_test),1);
        
        rew_thresh_all_mice(:,GAChnum) = day_align(:,rew_thresh_day );
        
        %% For collapsing mice
        
        %    Cued_day_1
        Cued_day_1_test = strfind(lower(day_align_filenames),lower([num2str(BLA_GACh(GAChnum)) '_Cued_Day_1']));
        
        Cued_day_1_day = find(~cellfun(@isempty,Cued_day_1_test),1);
        
        Cued_day_1_all_mice(:,GAChnum) = day_align(:,Cued_day_1_day);
        
        %    Cued_day_5
        Cued_day_5_test = strfind(lower(day_align_filenames),lower([num2str(BLA_GACh(GAChnum)) '_Cued_Day_5']));
        
        Cued_day_5_day = find(~cellfun(@isempty,Cued_day_5_test),1);
        
        Cued_day_5_all_mice(:,GAChnum) = day_align(:,Cued_day_5_day);
        
        
        %TO_day_01
        
        TO_day_01_test = strfind(lower(day_align_filenames),lower([num2str(BLA_GACh(GAChnum)) '_Timeout_Day_01']));
        
        TO_day_01_day = find(~cellfun(@isempty,TO_day_01_test),1);
        
        if ~isempty(TO_day_01_day)
            TO_day_01_day_all_mice(:,GAChnum) = day_align(:,TO_day_01_day);
        end
        
        
        
        %TO_day_03
        
        TO_day_03_test = strfind(lower(day_align_filenames),lower([num2str(BLA_GACh(GAChnum)) '_Timeout_Day_03']));
        
        TO_day_03_day = find(~cellfun(@isempty,TO_day_03_test),1);
        
        TO_day_03_day_all_mice(:,GAChnum) = day_align(:,TO_day_03_day);
        
        %    TO_10_rew
        
        TO_10_rew_test = strfind(lower(day_align_filenames),lower(TO_10_rew(GAChnum)));
        
        TO_10_rew_day = find(~cellfun(@isempty,TO_10_rew_test),1);
        
        TO_10_rew_day_all_mice(:,GAChnum) = day_align(:,TO_10_rew_day);
        
        
        %    TO_day_13
        
        TO_day_13_test = strfind(lower(day_align_filenames),lower([num2str(BLA_GACh(GAChnum)) '_Timeout_Day_13']));
        
        TO_day_13_day = find(~cellfun(@isempty,TO_day_13_test),1);
        
        TO_day_13_day_all_mice(:,GAChnum) = day_align(:,TO_day_13_day);
        
        % TO_day_15
        
        TO_day_15_test = strfind(lower(day_align_filenames),lower([num2str(BLA_GACh(GAChnum)) '_Timeout_Day_15']));
        
        TO_day_15_day = find(~cellfun(@isempty,TO_day_15_test),1);
        
        TO_day_15_day_all_mice(:,GAChnum) = day_align(:,TO_day_15_day);
        
        %Last_TO
        %simpler than other bc I found last TO day above
        TO_Last_day_all_mice(:,GAChnum) = day_align(:,TO_Last_day);
        
        %Ext_Day
        Ext_Day_test = strfind(lower(day_align_filenames),lower(Ext_Day(GAChnum)));
        
        Ext_Day_day = find(~cellfun(@isempty,Ext_Day_test),1);
        
        Ext_Day_day_all_mice(:,GAChnum) = day_align(:,Ext_Day_day);
        
        
    end
    
    %%  Make heatmap
    
    for idx = 1:size(variables,2)
        %pull out the means into the heatnumbers variable for plotting
        %example: heatnumbers = proper(:,1:2:end)'; Note: had to break
        %this into two lines bc couldn't get an apostrpohe in the eval
        %to work.
        eval(['heatnumbers =' variables{idx} ';']);
        heatnumbers = heatnumbers';
        
        %variables = ["correct" "tone" "incorrect" "receptacle" "randrec" "tonehit" "tonemiss" "inactive"];
        
        %clims for each individual action
        %if statement to change clims based on indicator
        if strcmp(indicator, 'BLA GACh')
            %clims = {[-2 5.5] [-.75 2.25] [-.6 1.21] [-1.5 5.25] [-.825 .7] [-2.25 2.75] [-1.75 3.5] [-2 5.5]};
            
            %clims matched to related actions
            %                 clims = {[-2 5.5] [-2.25 3.5] [-2 5.5] [-2 5.5] [-2 5.5] [-2.25 3.5] [-2.25 3.5] [-2 5.5]};
            clims = [-3 7];
            
            if mouse_ID == 813
                climits = [-3 6];
            end
            
            
        elseif  strcmp(indicator, 'NBM-BLA')
            %variables = ["correct" "tone" "incorrect" "receptacle" "randrec" "tonehit" "tonemiss" "inactive"];
            %clims = {[-0.7 1.1] [-.5 .6] [-.5 .425] [-.7 1.05] [-.6 .6] [-.625 .625] [-.7 1.3] [-2.5 3.5]};
            
            %clims matched to related actions
            %                 clims = {[-0.7 1.1] [-.7 1.3] [-0.7 1.1] [-.7 1.05] [-.7 1.05] [-.7 1.3] [-.7 1.3] [-.7 1.1]};
            clims = [-0.7 1.1];
            
        elseif mouse_ID == 3 || mouse_ID ==  4 || mouse_ID ==  5 || mouse_ID ==  6
            clims = [-1.7 3.5];
            
            %         elseif mouse_ID == 4
            %             climits = [-3 6];
            
        elseif mouse_ID == 8
            clims = [-3 8];
            
            
        end
        
        figure('Visible', 'off')
        cf = imagesc(graphtime,1, heatnumbers, clims);
        
        colormap jet
        nanmap = [0 0 0; colormap];
        colormap(nanmap);
        
        ax = gca;
        xlim([-5 5]);
        ax.TickDir = 'out';
        ax.XAxis.TickLength = [0.02 0.01];
        ax.XAxis.LineWidth = 1.75;
        
        %TO and Ext change based on when the different phases happened
        
        %lines to draw/label if BLA_GACh
        if any(mouse_ID == BLA_GACh)
            %         ax.YTick = [0.5 TO-0.5 rew_thresh_day - 0.5  Ext-0.5];
            yline(TO-0.5, 'LineWidth', 1.75);
            yline(Ext-0.5, 'LineWidth', 1.75);
            
            %double line drawing to make it brighter
            yline(rew_thresh_day - 0.5 , 'w', 'LineWidth', 1.75);
            yline(rew_thresh_day - 0.5 , 'w', 'LineWidth', 1.75);
            
            yline(TO_10_rew_day - 0.5 , '--w', 'LineWidth', 1.75);
            yline(TO_10_rew_day - 0.5 , '--w', 'LineWidth', 1.75);
            %         ax.YTickLabel = {'Cued', 'TO', 'Acq.','Ext.'};
            
            %for BLA GCaMP
        elseif  mouse_ID == 3 || mouse_ID ==4 || mouse_ID ==6
            %         ax.YTick = [0.5 TO-0.5 rew_thresh_day - 0.5  Ext-0.5];
            yline(TO-0.5, 'LineWidth', 1.75);
            yline(Ext-0.5, 'LineWidth', 1.75);
            
            %double line drawing to make it brighter
            yline(rew_thresh_day - 0.5 , 'w', 'LineWidth', 1.75);
            yline(rew_thresh_day - 0.5 , 'w', 'LineWidth', 1.75);
            
            
            %lines to draw/label for non-BLA_GACh
        else
            %         ax.YTick = [0.5 TO-0.5 Ext-0.5];
            yline(TO-0.5, 'LineWidth', 1.75);
            yline(Ext-0.5, 'LineWidth', 1.75);
            
            ax.YTickLabel = {'Cued', 'TO', 'Ext'};
            
        end
        
        
        
        set(gca,'YDir','normal')
        
        %remove yticks and yticklabels
        set(gca,'ytick',[])
        set(gca,'yticklabel',[])
        
        
        %         title([ num2str(mouse_ID) ' ' indicator, ' all phase ', variables{idx}],'fontsize',16)
        %         ylabel('Training Day','fontsize',16)
        %         xlabel('Seconds from event onset','fontsize',16)
        cb = colorbar;
        ylabel(cb, 'Z %\DeltaF/F0' ,'fontsize',16)
        xticks([-4:2:4]);
        
        
        
        
        print([outputfolder '\' num2str(mouse_ID) '_' indicator ' ' variables{idx}], '-dpng');
        
        
        close all
        
        
    end
    
    %write to xlsx file
    
    p_day_align_filenames = p_day_align_filenames';
    
    for idx = 1:size(prism_variables,2)
        eval([prism_variables{idx},' = [p_day_align_filenames; num2cell(', prism_variables{idx}, ')];']);
        writecell(eval(prism_variables{idx}), [outputfolder '\' num2str(mouse_ID) ' ' outputfile '.xlsx'], 'Sheet', prism_variables{idx});
    end
    
    
    
    clear day_align day_align_sem day_align_filenames correct tone incorrect receptacle randrec tonehit tonemiss inactive day_align_filenames
    clear p_correct p_tone p_incorrect p_receptacle p_randrec p_tonehit p_tonemiss p_inactive p_day_align_filenames
    
end

%% plot collapsed if BLA_GACh
if any(mouse_ID == BLA_GACh)
    
    %% Plot collapsed across mice (expanded collapse days)
    
    
    climits = [-2 6];
    
    mean_Cued_day_1 = nanmean(Cued_day_1_all_mice,2);
    mean_Cued_day_4 = nanmean(Cued_day_5_all_mice,2);
    mean_TO_day_01 = nanmean(TO_day_01_day_all_mice,2);
    mean_TO_day_03 = nanmean(TO_day_03_day_all_mice,2);
    mean_TO_10 = nanmean(TO_10_rew_day_all_mice,2);
    mean_TO_day_13 = nanmean(TO_day_13_day_all_mice,2);
    mean_TO_day_15 = nanmean(TO_day_15_day_all_mice,2);
    mean_rew_thresh = nanmean(rew_thresh_all_mice,2);
    mean_TO_Last = nanmean(TO_Last_day_all_mice,2);
    mean_Ext = nanmean(Ext_Day_day_all_mice,2);
    
    %spaced out a lot in this vector to make it easier to see separation
    mean_all_days = [mean_Cued_day_1    mean_Cued_day_4  mean_TO_day_01   mean_TO_day_03     mean_TO_10    ...
        mean_TO_day_13     mean_TO_day_15     mean_rew_thresh     mean_TO_Last   mean_Ext];
    
    figure
    cf = imagesc(graphtime,1,mean_all_days', climits); 
    
    colormap jet
    nanmap = [0 0 0; colormap];
    colormap(nanmap);
    
    
    ax = gca;
    xlim([-5 5]);
    xticks([-4:2:4]);
    ax.TickDir = 'out';
    ax.XAxis.TickLength = [0.02 0.01];
    ax.XAxis.LineWidth = 1.75;
    
    %TO and Ext change based on when the different phases happened
    %     ax.YTick = [1:8];
    %     ax.YTickLabel = {'Cued 1','Cued 5', 'TO 3', '10 Rew*', 'TO 13', 'TO 15', 'Acq*', 'Last TO'};
    
    set(gca,'YDir','normal') % put the trial numbers in order from bot to top on y-axis
    
    %remove yticks and yticklabels
    set(gca,'ytick',[])
    set(gca,'yticklabel',[])
    
    
    yline(3-0.5, 'LineWidth', 1.75);
    yline(5 - 0.5 , '--w', 'LineWidth', 1.75);
    yline(8 - 0.5 , 'w', 'LineWidth', 1.75);
    yline(10-0.5, 'LineWidth', 1.75);
    
    %draw white lines again to make brighter)
    yline(5 - 0.5 , '--w', 'LineWidth', 1.75);
    yline(8 - 0.5 , 'w', 'LineWidth', 1.75);
    
    %     title(indicator ,'fontsize',16)
    %     ylabel('Training Phase','fontsize',16)
    %     xlabel('Seconds','fontsize',16)
    cb = colorbar;
    ylabel(cb, 'Z %\DeltaF/F0' ,'fontsize',16)
    
    %Print png version of graph (save)
    print([outputfolder '\Collapsed incorrect days ' indicator], '-dpng');
    
    %zoom in
    %     xlim([beforetoneticks(2) afterrecticks(1)])
    %     print([outputfolder '\2 secs\Collapsed+ ' indicator ' Tone_NP_Rec'], '-dpng');
    
    
    
elseif any(mouse_ID == BLA_GCaMP)
    %% Plot collapsed across mice (expanded collapse days)
    
    
    
    climits = [-1.5 3.5];
    
    mean_Cued_day_1 = nanmean(Cued_day_1_all_mice,2);
    mean_Cued_day_4 = nanmean(Cued_day_4_all_mice,2);
    mean_TO_day_01 = nanmean(TO_day_01_day_all_mice,2);
    mean_TO_day_03 = nanmean(TO_day_03_day_all_mice,2);
    mean_rew_thresh = nanmean(rew_thresh_all_mice,2);
    mean_Ext = nanmean(Ext_Day_day_all_mice,2);
    
    %spaced out a lot in this vector to make it easier to see separation
    mean_all_days = [mean_Cued_day_1    mean_Cued_day_4   mean_TO_day_01  mean_TO_day_03   mean_rew_thresh    mean_Ext];
    
    figure
    cf = imagesc(graphtime,1,mean_all_days', climits);
    
    colormap jet
    nanmap = [0 0 0; colormap];
    colormap(nanmap);
    
    
    ax = gca;
    xlim([-5 5]);
    xticks([-4:2:4]);
    ax.TickDir = 'out';
    ax.XAxis.TickLength = [0.02 0.01];
    ax.XAxis.LineWidth = 1.75;
    
    %TO and Ext change based on when the different phases happened
    %     ax.YTick = [1:8];
    %     ax.YTickLabel = {'Cued 1','Cued 5', 'TO 3', '10 Rew*', 'TO 13', 'TO 15', 'Acq*', 'Last TO'};
    
    set(gca,'YDir','normal') % put the trial numbers in order from bot to top on y-axis
    
    %remove yticks and yticklabels
    set(gca,'ytick',[])
    set(gca,'yticklabel',[])
    
    
    yline(3-0.5, 'LineWidth', 1.75);
    yline(5 - 0.5 , 'w', 'LineWidth', 1.75);
    yline(6-0.5, 'LineWidth', 1.75);
    
    %double to increase brightness
     yline(5 - 0.5 , 'w', 'LineWidth', 1.75);
    
    %     title(indicator ,'fontsize',16)
    %     ylabel('Training Phase','fontsize',16)
    %     xlabel('Seconds','fontsize',16)
    cb = colorbar;
    ylabel(cb, 'Z %\DeltaF/F0' ,'fontsize',16)
    
    %Print png version of graph (save)
    print([outputfolder '\Collapsed incorrect days ' indicator], '-dpng');
    
    %zoom in
    %     xlim([beforetoneticks(2) afterrecticks(1)])
    %     print([outputfolder '\2 secs\Collapsed+ ' indicator ' Tone_NP_Rec'], '-dpng');
    
    
    
    
    
end




%print the version of the code used
fileID = fopen([outputfolder '\codeused.txt'],'w');
fprintf(fileID, codename);