% Burst Spikes Attenuation Analysis Option 1

function burstSpikeOption1(figuresEnabled, BSInterval)

% Prompt user to choose the data file:
[filename, filepath] = uigetfile({'*.txt','BSA Data File (*.txt)'},'Select Data File');
data_file = fullfile(filepath, filename);   %Creates a string for the filename and path
data = load(data_file); % Imports data from the chosen file
[row,~] = size(data); % Finds the dimensions of the data to be used in the FOR loops below
numOfCells = max(data(:,1),[],1); % Finds the number of cells in the data file
burstsPresent = 0; % If = 0 at end of analysis, will indicate no bursts present in the file for any cell
for cellNumber = 1:numOfCells
% Extract cell data for each cell in clustered in file
    index = 1;
    for i = 1:row
        if (data(i,1) == cellNumber)
            cellData(index,:) = data(i,:); 
            index = index + 1;
        end
    end
    [cellRow,~] = size(cellData);
    timeDifference = diff(cellData(:,2));
    index = 1;
    for i = 1:cellRow-1
        if timeDifference(i) < BSInterval
            temp(index,1) = i;
            temp(index,2) = timeDifference(i);
            index = index +1;
        end
    end
    if index > 3
        burstsPresent = 1; % Marker to show that bursts, as defined by user, are present for at least one cell
        burstGroup{1,1} = [temp(1,1) temp(1,1)+1]; %#ok<*AGROW>
        groupNumber = 1;
        for i = 2:length(temp)
            if (temp(i,1)-temp(i-1,1) == 1)
                burstGroup{1,groupNumber} = [burstGroup{1,groupNumber} temp(i,1)+1];
            else
                groupNumber = groupNumber+1;
                burstGroup{1,groupNumber} = [temp(i,1) temp(i,1)+1];
            end        
        end
        clear temp
        % Determine the number of spike bursts in each burst length group:
        for i = 1:groupNumber
            burstLength(i) = length(burstGroup{1,i});
        end

        minLength = min(burstLength);
        maxLength = max(burstLength);


        % time grouping
        shiftTime = cellData(:,2) - cellData(1,2);
        timeInterval = 15;  % minutes
        num_time_grp = ceil(shiftTime(length(shiftTime))/timeInterval);
       
        timeGroup = cell(1,num_time_grp);
        for i = 1:groupNumber
            index = ceil(shiftTime(burstGroup{1,i}(1))/timeInterval);
            if isequal(index, 0)
                index= 1;
            end
            timeGroup{1,index} = [timeGroup{1,index} i];
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Processing on wire 1, 2, 3, and 4

        % compute max amplitude of a burst group
        for i = 1:groupNumber
            [max_amp_w1(i), max_spike_w1(i)] = max(cellData(burstGroup{1,i},3));
            [max_amp_w2(i), max_spike_w2(i)] = max(cellData(burstGroup{1,i},4));
            [max_amp_w3(i), max_spike_w3(i)] = max(cellData(burstGroup{1,i},5));
            [max_amp_w4(i), max_spike_w4(i)] = max(cellData(burstGroup{1,i},6));
        end

        % compute last spike/first spike ratio
        for i = 1:groupNumber
            ratio_w1(i) = cellData(burstGroup{1,i}(burstLength(i)),3)/cellData(burstGroup{1,i}(1),3);
            ratio_w2(i) = cellData(burstGroup{1,i}(burstLength(i)),4)/cellData(burstGroup{1,i}(1),4);
            ratio_w3(i) = cellData(burstGroup{1,i}(burstLength(i)),5)/cellData(burstGroup{1,i}(1),5);
            ratio_w4(i) = cellData(burstGroup{1,i}(burstLength(i)),6)/cellData(burstGroup{1,i}(1),6);
        end

        % compute average ratio
        r_total_w1 = [];
        average_ratio_w1 = [];
        r_total_w2 = [];
        average_ratio_w2 = [];
        r_total_w3 = [];
        average_ratio_w3 = [];
        r_total_w4 = [];
        average_ratio_w4 = [];
        r_num = [];
        index = 1;
        for i = minLength:maxLength
            r_total_w1(index) = 0;
            r_total_w2(index) = 0;
            r_total_w3(index) = 0;
            r_total_w4(index) = 0;
            r_num(index) = 0;
            for j = 1:groupNumber
                if (burstLength(j) == i)
                    r_total_w1(index) = r_total_w1(index) + ratio_w1(j);
                    r_total_w2(index) = r_total_w2(index) + ratio_w2(j);
                    r_total_w3(index) = r_total_w3(index) + ratio_w3(j);
                    r_total_w4(index) = r_total_w4(index) + ratio_w4(j);
                    r_num(index) = r_num(index) + 1;
                end
            end
            if r_num(index) == 0
                average_ratio_w1(index) = 0;
                average_ratio_w2(index) = 0;
                average_ratio_w3(index) = 0;
                average_ratio_w4(index) = 0;
            else
                average_ratio_w1(index) =  r_total_w1(index)/r_num(index);
                average_ratio_w2(index) =  r_total_w2(index)/r_num(index);
                average_ratio_w3(index) =  r_total_w3(index)/r_num(index);
                average_ratio_w4(index) =  r_total_w4(index)/r_num(index);
            end
            index = index + 1;
        end

        % compute % max amplitude
        for i = 1:groupNumber
            spike_amp_percent_w1{1,i} = cellData(burstGroup{1,i},3)/max_amp_w1(i);
            spike_amp_percent_w2{1,i} = cellData(burstGroup{1,i},4)/max_amp_w2(i);
            spike_amp_percent_w3{1,i} = cellData(burstGroup{1,i},5)/max_amp_w3(i);
            spike_amp_percent_w4{1,i} = cellData(burstGroup{1,i},6)/max_amp_w4(i);
        end

        % time group process
        time_grp_mean_ratio_w1 = [];
        time_grp_std_ratio_w1 = [];
        time_grp_mean_ratio_w2 = [];
        time_grp_std_ratio_w2 = [];
        time_grp_mean_ratio_w3 = [];
        time_grp_std_ratio_w3 = [];
        time_grp_mean_ratio_w4 = [];
        time_grp_std_ratio_w4 = [];
        for i = 1:num_time_grp
            if (isempty(timeGroup{1,i}))
                time_grp_mean_ratio_w1(i) = 0;
                time_grp_std_ratio_w1(i) = 0;
                time_grp_mean_ratio_w2(i) = 0;
                time_grp_std_ratio_w2(i) = 0;
                time_grp_mean_ratio_w3(i) = 0;
                time_grp_std_ratio_w3(i) = 0;
                time_grp_mean_ratio_w4(i) = 0;
                time_grp_std_ratio_w4(i) = 0;
            else
                time_grp_mean_ratio_w1(i) = mean(ratio_w1(timeGroup{1,i}));
                time_grp_std_ratio_w1(i) = std(ratio_w1(timeGroup{1,i}));
                time_grp_mean_ratio_w2(i) = mean(ratio_w2(timeGroup{1,i}));
                time_grp_std_ratio_w2(i) = std(ratio_w2(timeGroup{1,i}));
                time_grp_mean_ratio_w3(i) = mean(ratio_w3(timeGroup{1,i}));
                time_grp_std_ratio_w3(i) = std(ratio_w3(timeGroup{1,i}));
                time_grp_mean_ratio_w4(i) = mean(ratio_w4(timeGroup{1,i}));
                time_grp_std_ratio_w4(i) = std(ratio_w4(timeGroup{1,i}));
            end
        end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Output to file

        output_filename = [filename(1:length(filename)-4),'_bsa_C',num2str(cellNumber),'.xls'];
        OutputFile = fopen(fullfile(filepath, output_filename),'w');

        fprintf(OutputFile,'Burst Spike Attenuation Analysis\n');
        fprintf(OutputFile,'Burst Interval: \t %d\n',BSInterval);
        fprintf(OutputFile,'Input file: \t %s\n',filename);
        fprintf(OutputFile,'Cell number: \t %d\n\n',cellNumber);

        fprintf(OutputFile,'\t\t\t Wire 1 \t\t\t\t\t\t Wire 2 \t\t\t\t\t\t Wire 3 \t\t\t\t\t\t Wire 4\n');
        fprintf(OutputFile,'Group # \t Spike # \t Burst Length \tTime Stamp \t');
        fprintf(OutputFile,'Amplitude \t First Spike \t Last Spike \t Last/First ratio \t Max. Spike \t %% Max. Amp. \t'); % wire 1
        fprintf(OutputFile,'Amplitude \t First Spike \t Last Spike \t Last/First ratio \t Max. Spike \t %% Max. Amp. \t'); % wire 2
        fprintf(OutputFile,'Amplitude \t First Spike \t Last Spike \t Last/First ratio \t Max. Spike \t %% Max. Amp. \t'); % wire 3
        fprintf(OutputFile,'Amplitude \t First Spike \t Last Spike \t Last/First ratio \t Max. Spike \t %% Max. Amp. \n'); % wire 4

        for i = 1:groupNumber
            for j = 1:burstLength(i)
                if j == 1
                    fprintf(OutputFile,'%d\t',i);                                                % group number
                    fprintf(OutputFile,'%d\t',j);                                                % spike number
                    fprintf(OutputFile,'%d\t',burstLength(i));                                  % burst length
                    fprintf(OutputFile,'%f\t',cellData(burstGroup{1,i}(j),2));                 % time stamp
                    % wire 1 data
                    fprintf(OutputFile,'%f\t',cellData(burstGroup{1,i}(j),3));                 % amplitude
                    fprintf(OutputFile,'%f\t',cellData(burstGroup{1,i}(1),3));                 % first spike
                    fprintf(OutputFile,'%f\t',cellData(burstGroup{1,i}(burstLength(i)),3));   % last spike
                    fprintf(OutputFile,'%f\t',ratio_w1(i));                                      % last/first ratio
                    fprintf(OutputFile,'%f (%d)\t',max_amp_w1(i),max_spike_w1(i));               % max spike
                    fprintf(OutputFile,'%f\t',spike_amp_percent_w1{1,i}(j));                     % percentage max spike
                    % wire 2 data
                    fprintf(OutputFile,'%f\t',cellData(burstGroup{1,i}(j),4));                 % amplitude
                    fprintf(OutputFile,'%f\t',cellData(burstGroup{1,i}(1),4));                 % first spike
                    fprintf(OutputFile,'%f\t',cellData(burstGroup{1,i}(burstLength(i)),4));   % last spike
                    fprintf(OutputFile,'%f\t',ratio_w2(i));                                      % last/first ratio
                    fprintf(OutputFile,'%f (%d)\t',max_amp_w2(i),max_spike_w2(i));               % max spike
                    fprintf(OutputFile,'%f\t',spike_amp_percent_w2{1,i}(j));                     % percentage max spike
                    % wire 3 data
                    fprintf(OutputFile,'%f\t',cellData(burstGroup{1,i}(j),5));                 % amplitude
                    fprintf(OutputFile,'%f\t',cellData(burstGroup{1,i}(1),5));                 % first spike
                    fprintf(OutputFile,'%f\t',cellData(burstGroup{1,i}(burstLength(i)),5));   % last spike
                    fprintf(OutputFile,'%f\t',ratio_w3(i));                                      % last/first ratio
                    fprintf(OutputFile,'%f (%d)\t',max_amp_w3(i),max_spike_w3(i));               % max spike
                    fprintf(OutputFile,'%f\t',spike_amp_percent_w3{1,i}(j));                     % percentage max spike
                    % wire 4 data
                    fprintf(OutputFile,'%f\t',cellData(burstGroup{1,i}(j),6));                 % amplitude
                    fprintf(OutputFile,'%f\t',cellData(burstGroup{1,i}(1),6));                 % first spike
                    fprintf(OutputFile,'%f\t',cellData(burstGroup{1,i}(burstLength(i)),6));   % last spike
                    fprintf(OutputFile,'%f\t',ratio_w4(i));                                      % last/first ratio
                    fprintf(OutputFile,'%f (%d)\t',max_amp_w4(i),max_spike_w4(i));               % max spike
                    fprintf(OutputFile,'%f\n',spike_amp_percent_w4{1,i}(j));                     % percentage max spike
                else
                    fprintf(OutputFile,'\t %d\t',j);
                    fprintf(OutputFile,'\t %f\t',cellData(burstGroup{1,i}(j),2));
                    % wire 1 data
                    fprintf(OutputFile,'%f\t',cellData(burstGroup{1,i}(j),3));                 % amplitude
                    fprintf(OutputFile,'\t\t\t\t%f\t',spike_amp_percent_w1{1,i}(j));             % percentage max spike
                    % wire 2 data
                    fprintf(OutputFile,'%f\t',cellData(burstGroup{1,i}(j),4));                 % amplitude
                    fprintf(OutputFile,'\t\t\t\t%f\t',spike_amp_percent_w2{1,i}(j));             % percentage max spike
                    % wire 3 data
                    fprintf(OutputFile,'%f\t',cellData(burstGroup{1,i}(j),5));                 % amplitude
                    fprintf(OutputFile,'\t\t\t\t%f\t',spike_amp_percent_w3{1,i}(j));             % percentage max spike
                    % wire 4 data
                    fprintf(OutputFile,'%f\t',cellData(burstGroup{1,i}(j),6));                 % amplitude
                    fprintf(OutputFile,'\t\t\t\t%f\n',spike_amp_percent_w4{1,i}(j));             % percentage max spike
                end
            end
        end

        fclose(OutputFile);

        %------------------ Plot figures ------------------%
        if isequal(figuresEnabled, 1)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for k = 1:4
                %-------- Wire 1 plots --------%
                figure;
                hold on;
                for i = 1:groupNumber
                    time_normalize = cellData(burstGroup{1,i},2) - cellData(burstGroup{1,i}(1),2);
                    plot(time_normalize*1000,spike_amp_percent_w1{1,i},'.-');
                end
                xlabel('Time (msec)');
                ylabel('Spike Amplitude (% Max Amp.)');
                title(['cell ',num2str(cellNumber), ', wire 1']);
                box on;
                hold off;

                figure;
                hold on;
                for i = 1:groupNumber
                    if (length(burstGroup{1,i}) == 3)
                        time_normalize = cellData(burstGroup{1,i},2) - cellData(burstGroup{1,i}(1),2);
                        plot([1 2 3],spike_amp_percent_w1{1,i},'.-');
                    end
                end
                xlabel('Burst Length (# of Spikes)');
                ylabel('Spike Amplitude (% Max Amp.)');
                axis([0 4 0.4 1]);
                title(['cell ',num2str(cellNumber), ', wire 1']);
                box on;
                hold off;

                figure;
                hold on;
                for i = 1:groupNumber
                    first_spike_time = cellData(burstGroup{1,i}(1),2);
                    plot(first_spike_time,cellData(burstGroup{1,i}(1),3),'ms');
                    plot(first_spike_time*ones(1,length(burstGroup{1,i})),cellData(burstGroup{1,i},3),'b-');
                    plot(first_spike_time*ones(1,length(burstGroup{1,i})-2),cellData(burstGroup{1,i}(2:length(burstGroup{1,i})-1),3),'b.-');
                    plot(first_spike_time,cellData(burstGroup{1,i}(length(burstGroup{1,i})),3),'go');
                end
                xlabel('Time (sec)');
                ylabel('Spike Amplitude');
                title(['cell ',num2str(cellNumber), ', wire 1']);
                box on;
                hold off;

                figure;
                plot([minLength:maxLength],average_ratio_w1,'.-');
                xlabel('Burst Length (# of Spikes)');
                ylabel('Last Spike/First Spike');
                title(['cell ',num2str(cellNumber), ', wire 1']);
                box on;

                % figure for time group ratio
                figure;
                hold on;
                plot([1:num_time_grp]*timeInterval,time_grp_mean_ratio_w1,'.-');
                for i = 1:num_time_grp
                    if (length(timeGroup{1,i}) ~= 0)
                        plot(i*timeInterval*ones(1,2),[time_grp_mean_ratio_w1(i)-time_grp_std_ratio_w1(i) time_grp_mean_ratio_w1(i)+time_grp_std_ratio_w1(i)],'+-');
                    end
                end
                xlabel('Time (sec.)');
                ylabel('Average Last Spike/First Spike ratio');
                title(['cell ',num2str(cellNumber), ', wire 1']);
                box on;
                hold off;

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                %-------- Wire 2 plots --------%
                figure;
                hold on;
                for i = 1:groupNumber
                    time_normalize = cellData(burstGroup{1,i},2) - cellData(burstGroup{1,i}(1),2);
                    plot(time_normalize*1000,spike_amp_percent_w2{1,i},'.-');
                end
                xlabel('Time (msec)');
                ylabel('Spike Amplitude (% Max Amp.)');
                title(['cell ',num2str(cellNumber), ', wire 2']);
                box on;
                hold off;

                figure;
                hold on;
                for i = 1:groupNumber
                    if (length(burstGroup{1,i}) == 3)
                        time_normalize = cellData(burstGroup{1,i},2) - cellData(burstGroup{1,i}(1),2);
                        plot([1 2 3],spike_amp_percent_w2{1,i},'.-');
                    end
                end
                xlabel('Burst Length (# of Spikes)');
                ylabel('Spike Amplitude (% Max Amp.)');
                axis([0 4 0.4 1]);
                title(['cell ',num2str(cellNumber), ', wire 2']);
                box on;
                hold off;

                figure;
                hold on;
                for i = 1:groupNumber
                    first_spike_time = cellData(burstGroup{1,i}(1),2);
                    plot(first_spike_time,cellData(burstGroup{1,i}(1),4),'ms');
                    plot(first_spike_time*ones(1,length(burstGroup{1,i})),cellData(burstGroup{1,i},4),'b-');
                    plot(first_spike_time*ones(1,length(burstGroup{1,i})-2),cellData(burstGroup{1,i}(2:length(burstGroup{1,i})-1),4),'b.-');
                    plot(first_spike_time,cellData(burstGroup{1,i}(length(burstGroup{1,i})),4),'go');
                end
                xlabel('Time (sec)');
                ylabel('Spike Amplitude');
                title(['cell ',num2str(cellNumber), ', wire 2']);
                box on;
                hold off;

                figure;
                plot([minLength:maxLength],average_ratio_w2,'.-');
                xlabel('Burst Length (# of Spikes)');
                ylabel('Last Spike/First Spike');
                title(['cell ',num2str(cellNumber), ', wire 2']);
                box on;

                % figure for time group ratio
                figure;
                hold on;
                plot([1:num_time_grp]*timeInterval,time_grp_mean_ratio_w2,'.-');
                for i = 1:num_time_grp
                    if (length(timeGroup{1,i}) ~= 0)
                        plot(i*timeInterval*ones(1,2),[time_grp_mean_ratio_w2(i)-time_grp_std_ratio_w2(i) time_grp_mean_ratio_w2(i)+time_grp_std_ratio_w2(i)],'+-');
                    end
                end
                xlabel('Time (sec.)');
                ylabel('Average Last Spike/First Spike ratio');
                title(['cell ',num2str(cellNumber), ', wire 2']);
                box on;
                hold off;

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                %-------- Wire 3 plots --------%
                figure;
                hold on;
                for i = 1:groupNumber
                    time_normalize = cellData(burstGroup{1,i},2) - cellData(burstGroup{1,i}(1),2);
                    plot(time_normalize*1000,spike_amp_percent_w3{1,i},'.-');
                end
                xlabel('Time (msec)');
                ylabel('Spike Amplitude (% Max Amp.)');
                title(['cell ',num2str(cellNumber), ', wire 3']);
                box on;
                hold off;

                figure;
                hold on;
                for i = 1:groupNumber
                    if (length(burstGroup{1,i}) == 3)
                        time_normalize = cellData(burstGroup{1,i},2) - cellData(burstGroup{1,i}(1),2);
                        plot([1 2 3],spike_amp_percent_w3{1,i},'.-');
                    end
                end
                xlabel('Burst Length (# of Spikes)');
                ylabel('Spike Amplitude (% Max Amp.)');
                axis([0 4 0.4 1]);
                title(['cell ',num2str(cellNumber), ', wire 3']);
                box on;
                hold off;

                figure;
                hold on;
                for i = 1:groupNumber
                    first_spike_time = cellData(burstGroup{1,i}(1),2);
                    plot(first_spike_time,cellData(burstGroup{1,i}(1),5),'ms');
                    plot(first_spike_time*ones(1,length(burstGroup{1,i})),cellData(burstGroup{1,i},5),'b-');
                    plot(first_spike_time*ones(1,length(burstGroup{1,i})-2),cellData(burstGroup{1,i}(2:length(burstGroup{1,i})-1),5),'b.-');
                    plot(first_spike_time,cellData(burstGroup{1,i}(length(burstGroup{1,i})),5),'go');
                end
                xlabel('Time (sec)');
                ylabel('Spike Amplitude');
                title(['cell ',num2str(cellNumber), ', wire 3']);
                box on;
                hold off;

                figure;
                plot([minLength:maxLength],average_ratio_w3,'.-');
                xlabel('Burst Length (# of Spikes)');
                ylabel('Last Spike/First Spike');
                title(['cell ',num2str(cellNumber), ', wire 3']);
                box on;

                % figure for time group ratio
                figure;
                hold on;
                plot([1:num_time_grp]*timeInterval,time_grp_mean_ratio_w3,'.-');
                for i = 1:num_time_grp
                    if (length(timeGroup{1,i}) ~= 0)
                        plot(i*timeInterval*ones(1,2),[time_grp_mean_ratio_w3(i)-time_grp_std_ratio_w3(i) time_grp_mean_ratio_w3(i)+time_grp_std_ratio_w3(i)],'+-');
                    end
                end
                xlabel('Time (sec.)');
                ylabel('Average Last Spike/First Spike ratio');
                title(['cell ',num2str(cellNumber), ', wire 3']);
                box on;
                hold off;

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                %-------- Wire 4 plots --------%
                figure;
                hold on;
                for i = 1:groupNumber
                    time_normalize = cellData(burstGroup{1,i},2) - cellData(burstGroup{1,i}(1),2);
                    plot(time_normalize*1000,spike_amp_percent_w4{1,i},'.-');
                end
                xlabel('Time (msec)');
                ylabel('Spike Amplitude (% Max Amp.)');
                title(['cell ',num2str(cellNumber), ', wire 4']);
                box on;
                hold off;

                figure;
                hold on;
                for i = 1:groupNumber
                    if (length(burstGroup{1,i}) == 3)
                        time_normalize = cellData(burstGroup{1,i},2) - cellData(burstGroup{1,i}(1),2);
                        plot([1 2 3],spike_amp_percent_w4{1,i},'.-');
                    end
                end
                xlabel('Burst Length (# of Spikes)');
                ylabel('Spike Amplitude (% Max Amp.)');
                axis([0 4 0.4 1]);
                title(['cell ',num2str(cellNumber), ', wire 4']);
                box on;
                hold off;

                figure;
                hold on;
                for i = 1:groupNumber
                    first_spike_time = cellData(burstGroup{1,i}(1),2);
                    plot(first_spike_time,cellData(burstGroup{1,i}(1),6),'ms');
                    plot(first_spike_time*ones(1,length(burstGroup{1,i})),cellData(burstGroup{1,i},6),'b-');
                    plot(first_spike_time*ones(1,length(burstGroup{1,i})-2),cellData(burstGroup{1,i}(2:length(burstGroup{1,i})-1),6),'b.-');
                    plot(first_spike_time,cellData(burstGroup{1,i}(length(burstGroup{1,i})),6),'go');
                end
                xlabel('Time (sec)');
                ylabel('Spike Amplitude');
                title(['cell ',num2str(cellNumber), ', wire 4']);
                box on;
                hold off;

                figure;
                plot([minLength:maxLength],average_ratio_w4,'.-');
                xlabel('Burst Length (# of Spikes)');
                ylabel('Last Spike/First Spike');
                title(['cell ',num2str(cellNumber), ', wire 4']);
                box on;

                % figure for time group ratio
                figure;
                hold on;
                plot((1:num_time_grp)*timeInterval,time_grp_mean_ratio_w4,'.-');
                for i = 1:num_time_grp
                    if (length(timeGroup{1,i}) ~= 0)
                        plot(i*timeInterval*ones(1,2),[time_grp_mean_ratio_w4(i)-time_grp_std_ratio_w4(i) time_grp_mean_ratio_w4(i)+time_grp_std_ratio_w4(i)],'+-');
                    end
                end
                xlabel('Time (sec.)');
                ylabel('Average Last Spike/First Spike ratio');
                title(['cell ',num2str(cellNumber), ', wire 4']);
                box on;
                hold off;
            end
        pause    
        end
    end
clear cellData burstGroup burstLength timeGroup spike_amp_percent_w1 spike_amp_percent_w2 spike_amp_percent_w3 spike_amp_percent_w4
end
if isequal(burstsPresent, 0)
    msgbox('No bursts were present for any cell given the defined criteria.','Pop-up');
else
    msgbox('Spike burst processing is complete.','Pop-up');
end
