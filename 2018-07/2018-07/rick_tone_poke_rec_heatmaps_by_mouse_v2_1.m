%% rick_tone_to_poke_heatmaps_by_mouse_plots_v2_1
%for use with Hannah_Rufina_FP_v1
%will be used for both data sets

%v2_1: Added ext days
%v2: changing labeling+numbering for publication. Also changing colormap to jet


%built from rick_tone_to_poke_heatmaps_by_mouse_plots_v2.ish
%v3: adding rec to make it tone_poke_rec_heatmaps_by_mouse
%v2: collapse across mice for select days based on behavior
%v1_1: add loading


clear;

exp = '2018-07';
% exp = '2019-06';
codename = 'rick_tone_poke_rec_heatmaps_by_mouse_v2_1';

%Groups
%2019-06
NBM_BLA = [810 811 812 819];
BLA_GACh = [813 814 820 827];

%2018-07
%no 8 for now
% BLA_GCaMP = [3 4 5 6];
BLA_GCaMP = [3 4 6];
%     BLA_GCaMP = [3 4 5 6 8];

%% Set folder/files

if strcmp(exp,'2019-06')
    
    load('C:\Users\User\Google Drive\2019-06 NBM-BLA + GACh FP\Doric\Processed\2019-06 App MATLAB\2019-06 App MATLAB Outputrawandnamesonly24-Dec-2019.mat');
    
    outputfolder = 'C:\Users\User\Google Drive\2019-06 NBM-BLA + GACh FP\Doric\Processed\2019-06 App MATLAB\Summary TonetoPoketoRec Heat';
    outputfile = '2019-06 App MATLAB tonetopoketorec heat by mouse data';
    
    %file to skip
    skips = ["827_Timeout_Day_06"; "813_Timeout_Day_12"; "820_Timeout_Day_06"; "814_Timeout_Day_01"; "814_Timeout_Day_07"];
    
elseif strcmp(exp,'2018-07')
    
    load('C:\Users\User\Google Drive\2018-07 BLA Fiber Pho\Doric\Processed\2018-07 App MATLAB\2018-07 App MATLAB Outputrawandnamesonly22-Dec-2019.mat');
    
    outputfolder = 'C:\Users\User\Google Drive\2018-07 BLA Fiber Pho\Doric\Processed\2018-07 App MATLAB\Summary TonetoPoketoRec Heat';
    outputfile = '2018-07 App MATLAB tonetopoketorec heat by mouse data';
    
    %file to skip
    skips = ["HB03_Timeout_Day_12"; "HB04_Timeout_Day_11"; "HB04_Timeout_Day_13"; "HB05_Timeout_Day_09"; "HB06_Timeout_Day_09";  "HB06_Timeout_Day_11"; "HB08_Timeout_Day_12"];
    
end

%initialize
data_mouse_ID = zeros(size(filenames,1),1);


%% Organize data and Make Heat Map
%transposing for plotting purposes, using '

if strcmp(exp,'2019-06')
    
    %prep for cut down data to just one mouse
    
    for ii = 1:size(filenames,1)
        data_mouse_ID(ii) = str2double(filenames{ii}(11:13));
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
    
    for ii = 1:size(filenames,1)
        data_mouse_ID(ii) = str2double(filenames{ii}(14));
    end
    
    all_mouse_ID= unique(data_mouse_ID);
    
    %for drawing white line
    %     rew_threshold = ["3_Timeout_Day_08"; "4_Timeout_Day_08"; "5 was dud"; "6_Timeout_Day_13"];
    rew_threshold = ["3_Timeout_Day_08"; "4_Timeout_Day_08"; "6_Timeout_Day_13"];
    
    Ext_Day = ["3_ZZExt_Day_1"; "4_ZZExt_Day_1"; "6_ZZExt_Day_2"];
    
end



%set for loop num

if strcmp(exp,'2019-06')
    
    nummer = 1:size(all_mouse_ID,1);
    
elseif strcmp(exp,'2018-07')
    
    nummer = [1 2 4];
    
end


for num = nummer
% for num = 1:size(all_mouse_ID,1)
% for num = [4 5 7 8]
    % for num = 5
    
    
    
    %Define mouse_ID number for the run of the for loop
    mouse_ID = all_mouse_ID(num);
    
    
    
    %What indicator is it?
    if any(mouse_ID == NBM_BLA)
        indicator = 'NBM-BLA';
        climits = [-2 4.5];
        
    elseif any(mouse_ID == BLA_GACh)
        indicator = 'BLA GACh';
        climits = [-3 7];
        GAChnum=find(BLA_GACh==mouse_ID);
        
    elseif any(mouse_ID == BLA_GCaMP)
        indicator = 'BLA GCaMP';
        climits = [-1.7 3.5];
        BLAGCaMP_num=find(BLA_GCaMP==mouse_ID);
        
        if mouse_ID == 8
            climits = [-3 8];
            
        end
        
    end
    
    %originally had 813's limits lower but not sure why
    %     %come up with something more elegant for changing the climits for
    %     %individual mice if doing this for a lot
    %     if mouse_ID == 813
    %         climits = [-3 6];
    %     end
    %
    
    
    %trim data and filenames to just current mouse
    mousedata = rawtogether((data_mouse_ID(:,1) == mouse_ID),:);
    mousefiles = filenames((data_mouse_ID(:,1) == mouse_ID),:);
    
    %use day_counter to prevent black bar when skipping days
    day_counter = 0;
    
    %     day_align = NaN(611+lat*122+611,size(mousedata,1));
    %     day_align_sem = NaN(611+lat*122+611,size(mousedata,1));
    %
    for file = 1:size(mousedata,1)
        
        %instead of finding longest latency, standardize to a 4 sec
        %latency
        %use a 1 sec pull for
        %if you want to change the amount you pull, change lat
        lat = 4;
        half_lat = lat*122/2;
        
        rew_lat = 1;
        half_rew_lat = rew_lat*122/2;
        
        divider = 16;
        
        %skip shitters
        if any(strcmpi(mousefiles{file}(11:end-6),skips))
            
            continue
            
            %make sure there's actually something to plot (at least one
            %reward), if not, skips to next
        elseif size(mousedata{file,1},2)==0
            continue
            
            %find mean of each day
        else
            
            %if the day isn't skipped, increase day counter. This will
            %prevent black bars for skipped days
            day_counter = day_counter+1;
            
            %
            %
            %             %create a time vector based on longestlat, with t=0 is tone onset
            %             timevector = mousedata{1,1}{2,2}(1:1710,1)-mousedata{1,1}{2,2}(611,1);
            %             Saved in C:\Users\User\Google Drive\2019-06 NBM-BLA + GACh FP\Doric\Processed\2019-06 App MATLAB\Mouse TonetoPoke Heat
            
            %preallocate aligntogether as NaN
            %doing 5 sec before tone + tone + half_lat + divider + half_lat
            % + poke + half_rew_lat + divider + half_rew_lat + rec + 5 sec
            % after rec
            
            %find number of non empty
            not_empty_rewards = find(~cellfun(@isempty,mousedata{file,1}(1,:)));
            
            aligntogether = NaN(610 + 1 + half_lat + divider + half_lat + 1 + half_rew_lat + divider + half_rew_lat + 1 + 610 ,size(not_empty_rewards,2));
            
            
            align_reward_counter = 0;
            
            %cycle through rewards of mousedata that aren't empty
            for reward = not_empty_rewards
                %using this counter to skip the rewards that didn't
                %have a rec entry following NP within 5 secs (which are
                %empty matrices in rawtogether)
                align_reward_counter = align_reward_counter+1 ;
                
                %grab the index of actions
                tone = find(mousedata{file,1}{1,reward}(:,3) == 2);
                poke = find(mousedata{file,1}{1,reward}(:,3) == 1);
                rec = find(mousedata{file,1}{1,reward}(:,3) == 4);
                
                %determine half of actual latencies
                half_actual_lat = round((poke-tone)/2);
                half_actual_rew_lat= round((rec-poke)/2);
                
                %determine min between actual and default
                min_pull_tone_poke = min(half_actual_lat,half_lat);
                min_pull_poke_rec = min(half_actual_rew_lat,half_rew_lat);
                
                
                stop_insert_tone = 611 + min_pull_tone_poke;
                
                %half_lats used here to skip the max lat before divider
                %also used to determine how shy of half_lat it should start
                %inserting poke
                start_insert_poke = 611 + half_lat + divider + 1 + half_lat - min_pull_tone_poke;
                stop_insert_poke = 611 + half_lat + divider + 1 + half_lat + min_pull_poke_rec;
                
                %plus used here because I call this variable using end - it
                start_insert_rec = 610 + min_pull_poke_rec;
                
                
                %add first bit, 5 sec before tone to half_lat after tone
                aligntogether(1:stop_insert_tone,align_reward_counter)  = mousedata{file,1}{1,reward}(1:stop_insert_tone,2);
                
                %add middle bit
                aligntogether(start_insert_poke:stop_insert_poke,align_reward_counter) = mousedata{file,1}{1,reward}(poke-min_pull_tone_poke:poke+min_pull_poke_rec,2);
                
                %add last bit, half_rew_lat before rec to 5 sec after
                aligntogether(end-start_insert_rec:end,align_reward_counter) = mousedata{file,1}{1,reward}(end-610-min_pull_poke_rec:end,2);
            end
            
            %take the file name
            %Note: the names are going in as columns to reflect how data is
            %being stored
            day_align_filenames{day_counter,1} = mousefiles{file,1};
            
            day_align(:,day_counter) = nanmean(aligntogether,2);
            %take sem if want to plot it later
            day_align_sem(:,day_counter) = nanstd(aligntogether,0,2)/sqrt(size(aligntogether,2));
            
            %
            %             day_align(:,file) = nanmean(aligntogether,2);
            %             %take sem if want to plot it later
            %             day_align_sem(:,file) = nanstd(aligntogether,0,2)/sqrt(size(aligntogether,2));
            %
        end
        
    end
    
    %% Find start day of phases and threshold days
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
    %% Plot and save
    
    
%     figure('Visible', 'off')
    figure
    cf = imagesc(day_align', climits); % not using the actual time since the number
    
    colormap jet
    nanmap = [0 0 0; colormap];
    colormap(nanmap);
    
    
    
    %beforetoneticks includes tone tick
    beforetoneticks = 1+(610/5)*[1 3 5];
    
    
    %latency ticks
    lat_tick = 611 + half_lat + divider/2;
    
    %poke_tick
    poke_tick = 611 + half_lat + divider + half_lat + 1;
    
    %rew_lat_ticks
    rew_lat_tick = 611 + half_lat + divider + half_lat + 1 + half_rew_lat + divider/2;
    
    rec_tick = 611 + half_lat + divider + half_lat + 1 + half_rew_lat + divider + half_rew_lat + 1;
    
    %may needto play around with this
    afterrecticks = size(aligntogether,1)-(122*[3 1]-1);
    
    
    ax = gca;
    
    %too crowded with 0.5/-.5
    %     ax.XTick = [beforetoneticks lat_tick poke_tick rew_lat_tick rec_tick afterrecticks];
    %     ax.XTickLabel = { '-4', '-2',  'Tone', '2 / -2', 'NP','0.5/-.5' ,'Rec', '2',  '4'};
    
    ax.XTick = [beforetoneticks lat_tick poke_tick rec_tick afterrecticks];
    ax.XTickLabel = { '-4', '-2',  'Tone', '2 / -2', 'NP','Rec', '2',  '4'};
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
    
    %     title([num2str(mouse_ID) ' ' indicator],'fontsize',16)
    %     ylabel('Training Phase','fontsize',16)
    %     xlabel('Seconds','fontsize',16)
    cb = colorbar;
    ylabel(cb, 'Z %\DeltaF/F0' ,'fontsize',16)
    
    
    
    
    
    %Print png version of graph (save)
    print([outputfolder '\' num2str(mouse_ID) ' ' indicator ' Tone_NP_Rec'], '-dpng');
    
    %zoom in
    %     xlim([beforetoneticks(2) afterrecticks(1)])
    %     print([outputfolder '\2 secs\' num2str(mouse_ID) ' ' indicator ' Tone_NP_Rec'], '-dpng');
    %
    
    clear day_align day_align_sem day_align_filenames
    
    
    
    
    %         close figures
    close all
    
    
end


%% plot collapsed if BLA_GACh
if any(mouse_ID == BLA_GACh)
    
    %% Plot collapsed across mice (expanded collapse days)
    
    
    climits = [-2 6];
    
    mean_Cued_day_1 = nanmean(Cued_day_1_all_mice,2);
    mean_Cued_day_4 = nanmean(Cued_day_5_all_mice,2);
    mean_TO_day_03 = nanmean(TO_day_03_day_all_mice,2);
    mean_TO_10 = nanmean(TO_10_rew_day_all_mice,2);
    mean_TO_day_13 = nanmean(TO_day_13_day_all_mice,2);
    mean_TO_day_15 = nanmean(TO_day_15_day_all_mice,2);
    mean_rew_thresh = nanmean(rew_thresh_all_mice,2);
    mean_TO_Last = nanmean(TO_Last_day_all_mice,2);
    mean_Ext = nanmean(Ext_Day_day_all_mice,2);
    
    %spaced out a lot in this vector to make it easier to see separation
    mean_all_days = [mean_Cued_day_1    mean_Cued_day_4     mean_TO_day_03     mean_TO_10    ...
        mean_TO_day_13     mean_TO_day_15     mean_rew_thresh     mean_TO_Last   mean_Ext];
    
    figure
    cf = imagesc(mean_all_days', climits); % not using the actual time since the number
    
    colormap jet
    nanmap = [0 0 0; colormap];
    colormap(nanmap);
    
    
    ax = gca;
    ax.XTick = [beforetoneticks lat_tick poke_tick rec_tick afterrecticks];
    ax.XTickLabel = { '-4', '-2',  'Tone', '2 / -2', 'NP','Rec', '2',  '4'};
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
    yline(4 - 0.5 , '--w', 'LineWidth', 1.75);
    yline(7 - 0.5 , 'w', 'LineWidth', 1.75);
    yline(9-0.5, 'LineWidth', 1.75);
    
    %draw white lines again to make brighter)
    yline(4 - 0.5 , '--w', 'LineWidth', 1.75);
    yline(7 - 0.5 , 'w', 'LineWidth', 1.75);
    
    %     title(indicator ,'fontsize',16)
    %     ylabel('Training Phase','fontsize',16)
    %     xlabel('Seconds','fontsize',16)
    cb = colorbar;
    ylabel(cb, 'Z %\DeltaF/F0' ,'fontsize',16)
    
    %Print png version of graph (save)
    print([outputfolder '\Collapsed+ ' indicator ' Tone_NP_Rec'], '-dpng');
    
    %zoom in
    %     xlim([beforetoneticks(2) afterrecticks(1)])
    %     print([outputfolder '\2 secs\Collapsed+ ' indicator ' Tone_NP_Rec'], '-dpng');
    
    
    
elseif any(mouse_ID == BLA_GCaMP)
    %% Plot collapsed across mice (expanded collapse days)
    
    
    
    climits = [-1.5 3.5];
    
    mean_Cued_day_1 = nanmean(Cued_day_1_all_mice,2);
    mean_Cued_day_4 = nanmean(Cued_day_4_all_mice,2);
    mean_TO_day_03 = nanmean(TO_day_03_day_all_mice,2);
    mean_rew_thresh = nanmean(rew_thresh_all_mice,2);
    mean_Ext = nanmean(Ext_Day_day_all_mice,2);
    
    %spaced out a lot in this vector to make it easier to see separation
    mean_all_days = [mean_Cued_day_1    mean_Cued_day_4     mean_TO_day_03   mean_rew_thresh    mean_Ext];
    
    figure
    cf = imagesc(mean_all_days', climits); % not using the actual time since the number
    
    colormap jet
    nanmap = [0 0 0; colormap];
    colormap(nanmap);
    
    
    ax = gca;
    ax.XTick = [beforetoneticks lat_tick poke_tick rec_tick afterrecticks];
    ax.XTickLabel = { '-4', '-2',  'Tone', '2 / -2', 'NP','Rec', '2',  '4'};
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
    yline(4 - 0.5 , 'w', 'LineWidth', 1.75);
    yline(5-0.5, 'LineWidth', 1.75);
    
    %double to increase brightness
     yline(4 - 0.5 , 'w', 'LineWidth', 1.75);
    
    %     title(indicator ,'fontsize',16)
    %     ylabel('Training Phase','fontsize',16)
    %     xlabel('Seconds','fontsize',16)
    cb = colorbar;
    ylabel(cb, 'Z %\DeltaF/F0' ,'fontsize',16)
    
    %Print png version of graph (save)
    print([outputfolder '\Collapsed+ ' indicator ' Tone_NP_Rec'], '-dpng');
    
    %zoom in
    %     xlim([beforetoneticks(2) afterrecticks(1)])
    %     print([outputfolder '\2 secs\Collapsed+ ' indicator ' Tone_NP_Rec'], '-dpng');
    
    
    
    
    
end




%% Print code version text file

%print the version of the code used
fileID = fopen([outputfolder '\codeused.txt'],'w');
fprintf(fileID, codename);

close all