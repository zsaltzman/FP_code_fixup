%% rick_mean_SEM_calc_indiv_plots_v3
    %for use with Hannah_Rufina_FP_vX
    

%Previously known as: rick_Smooth_BIN_NEWv4
    %changed name bc didn't make any sense. The first half of this program
    %organizes all of the excel files with the previx "MATLAB_" and
    %calculates means. 
    %v4 - nanmean and nanstd, like used for 2018-07 reanalysis
    %v3 - improve graphs
    %v2 - skip days when the fiber came off the head during the session

clear;
load(getPipelineVarsFilename);

%reading in MATLAB_... files in 2019-06 App MATLAB folder
codename = 'rick_mean_SEM..._v3';

%Groups
NBM_BLA = [810 811 812 819];
BLA_GACh = [813 814 820 827];

BLA_GCaMP = [3 4 5 6];


%% Set folder/files   
folder = FP_COMPILE_DIRECTORY;
outputfolder = FP_MEAN_SEM_DIRECTORY;
timestampfile = FP_TIMESTAMP_FILE;
outputfile = '2018-07 App MATLAB graph data';

%file to skip
skips = ["HB03_Timeout_Day_12"; "HB04_Timeout_Day_11"; "HB04_Timeout_Day_13"; "HB05_Timeout_Day_09"; "HB06_Timeout_Day_09";  "HB06_Timeout_Day_11"; "HB08_Timeout_Day_12"];

% Make some pretty colors for later plotting
% http://math.loyola.edu/~loberbro/matlab/html/colorsInMatlab.html
red = [0.8500, 0.3250, 0.0980];
green = [0.4660, 0.6740, 0.1880];
cyan = [0.3010, 0.7450, 0.9330];
gray1 = [.7 .7 .7 .25];


%% read data

%Auto Import Data
C = dir([folder, '\*.xlsx']);
filenames = {C(:).name}.';
datanames = cell(length(C),1);
graphdata = cell(length(C),1);

variables = ["correct" "tone" "incorrect" "receptacle" "randrec" "tonehit" "tonemiss" "inactive"];


for ii = 1:length(C)
    % Create the full file name and partial filename
    fullname = [folder '\' C(ii).name];
    
   
    datanames{ii,1} = filenames(ii);
    
    %skip bad days (fiber slipping off)
    if any(strcmpi(datanames{ii}{1}(8:end-5),skips))
       
        %need to add this skip if statement below as well
        continue
    
    % Read in the data
    else    
    [~,sheets] = xlsfinfo(fullname);
    
        for sheetsidx = 3:size(sheets,2)
            graphdataidx=find(strcmpi(sheets{sheetsidx},variables));
            graphdata{ii,graphdataidx} = xlsread(fullname,sheets{sheetsidx});
        end
    
    end
end



%import timestamp
time = xlsread(timestampfile);

%% Calculate averages and sems

graphmean = cell(size(graphdata));
graphsem = cell(size(graphdata));

%loop for all days
for file = 1:size(graphdata,1)
    if any(strcmpi(datanames{file}{1}(8:end-5),skips))
        
        
        continue
        
    else
    %loop for all variables
       for variable = 1:size(graphdata,2)
           %only do if cell ~isempty
           if ~isempty(graphdata{file,variable})
               graphmean{file,variable} = nanmean(graphdata{file,variable},2);
               graphsem{file,variable} = nanstd(graphdata{file,variable},0,2)/sqrt(size(graphdata{file,variable},2));
           end
       end
    end
end
save(FP_INDIVIDUAL_DAY_DATA_FILENAME, '-v7.3');


%% Make a Peri-Event Stimulus Plot and Heat Map
%transposing all variables for plotting purposes, using '

graphtime = time';


for file = 1:size(graphdata,1)
    
    %skip bad files
    if any(strcmp(datanames{file}{1}(8:end-5),skips))
                
        continue
        
        
    elseif any(str2double(datanames{file,1}{1}(8:10)) == NBM_BLA)
        
        
        continue
    
    else
        %determine the day of mice
        mouse_day = datanames{file,1}{1}(8:end-5);
        mouse_ID = datanames{file,1}{1}(11);
        indicator = 'BLA GCaMP6s';
        ylimits = [-1.5 4];
        
        for action = 1:size(graphdata,2)
            if ~isempty(graphdata{file,action})
                
                mean_allSignals = graphmean{file,action}';
                std_allSignals = graphsem{file,action}';
                allSignals = graphdata{file,action}';

                % Make a standard deviation fill for mean signal
                xx = [graphtime, fliplr(graphtime)];
                yy = [mean_allSignals + std_allSignals,...
                    fliplr(mean_allSignals - std_allSignals)];

                %figure stuff
                figure('Position',[100, 100, 600, 750],'Visible', 'off')
                subplot(2,1,1)

                hold on;


                % Set specs for min and max value of event line.
                % Min and max of either std or one of the signal snip traces
                linemin = ylimits(1);
                linemax = ylimits(2);

                % Plot the signals 
                p1 = plot(graphtime, allSignals', 'color', gray1);
                
                xlim([-5 5]);
                ylim(ylimits);
                
                %not decided on whether I want the line or all signals first
                % Plot the line next
                l1 = line([0 0], [linemin, linemax],...
                    'color','cyan', 'LineStyle', '-', 'LineWidth', 2);

                %plot sem area
                h = fill(xx, yy, 'g'); % plot this now for overlay purposes
                set(h, 'facealpha', 0.25, 'edgecolor', 'none');

                % Plot the mean signals
                p2 = plot(graphtime, mean_allSignals, 'color', green, 'LineWidth', 1);
                hold off;

                % Make a legend and do other plot things
                legend([l1, p1(1), p2, h],...
                    {[variables{action} ' Onset'],'Trial Traces','Mean Response','SEM'},...
                    'Location','northeast');
                mouse_day = strrep(mouse_day,'_', ' ');
                title([mouse_ID ' ' indicator ' ' variables{action} ' ' mouse_day],'fontsize',16);
                ylabel('Z %\DeltaF/F0','fontsize',16);
                xticks([-5 -4 -3 -2 -1 0 1 2 3 4 5]);
                
                % Make an invisible colorbar so this plot aligns with one below it
                temp_cb = colorbar('Visible', 'off');

                % Heat map
                subplot(2,1,2)
                imagesc(graphtime, 1, allSignals, ylimits); % this is the heatmap
                xlim([-5 5]);
                
                set(gca,'YDir','normal') % put the trial numbers in better order on y-axis
               
                colormap jet;
                nanmap = [0 0 0; colormap];
                colormap(nanmap);

                title([num2str(mouse_ID) ' ' variables{action} ' Heat Map'],'fontsize',16)
                ylabel('Trial Number','fontsize',16)
                xlabel('Seconds from event onset','fontsize',16)
                cb = colorbar;
                ylabel(cb, 'Z %\DeltaF/F0','fontsize',16)
                xticks([-5 -4 -3 -2 -1 0 1 2 3 4 5]);
                

                %Print png version of graph (save)
                print([outputfolder '\' mouse_day '_' variables{action}], '-dpng');

                close all
            end
        end
    end
end

