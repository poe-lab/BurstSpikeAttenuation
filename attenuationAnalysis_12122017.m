function attenuationAnalysis_12122017(filename, numberOfCells, startInterval, stopInterval,...
    ratNumber, tetrodeNumber, expDate, isolateChecked, isolatedStates,sleepFileName)
% xlsHeader = {'Rat', 'Tetrode', 'Date', 'IntervalStart (s)', 'IntervalStop (s)'};
% xlsHeaderNumbers = [ratNumber tetrodeNumber expDate startInterval(1) stopInterval(1);...
%     ratNumber tetrodeNumber expDate startInterval(2) stopInterval(2)];

% Load the Sleep Scorer file if isolating states for the analysis:
if isequal(isolateChecked, 1)
    scoredStates = xlsread(sleepFileName);
    stateTargetInterval{1,1}=[];
    stateTargetInterval{1,2}=[];
    for i = 1:2
        isoCount = 1;
        isoStatesIntervalIndex{i} = find(scoredStates(:,2) > startInterval(i) & scoredStates(:,2) < stopInterval(i));
        isoStatesInterval{i} = scoredStates(isoStatesIntervalIndex{i},:);
        lengthIsoState(i) =length(isoStatesInterval{i});
        for j = 1:lengthIsoState(i)
            if isequal(isolatedStates(isoStatesInterval{i}(j,3)),1)
                isoStatesInterval{i}(j,3) = 1;
            else
                isoStatesInterval{i}(j,3) = 0;   
            end
            
        end
        firstIsoInd = find(isoStatesInterval{i}(:,3)==1, 1);
        if isempty(firstIsoInd)
            isoStatesInterval{i} = [];
        else
            isoStatesInterval{i}(1:firstIsoInd-1,:) = [];
        end
        lengthIsoState(i) =length(isoStatesInterval{i}); %Recalculate the length of the array due to removal of initial rows.
        if lengthIsoState(i) < 2
            stateTargetInterval{i} = [];
        else
            stateTargetInterval{i}(isoCount,1) = isoStatesInterval{i}(1,2);
            %The following FOR loop generates isolated intervals based on user-selected states:
            for j = 2:lengthIsoState(i)    
                if isequal(isoStatesInterval{i}(j,3),1)
                    if isequal(isoStatesInterval{i}(j-1,3),0)
                        stateTargetInterval{i}(isoCount,1) = isoStatesInterval{i}(j,2); 
                    end
                    if isequal(j, lengthIsoState(i))
                        stateTargetInterval{i}(isoCount,2) = isoStatesInterval{i}(j,2);
                    end
                elseif isequal(isoStatesInterval{i}(j,3),0) && isequal(isoStatesInterval{i}(j-1,3),1)
                    stateTargetInterval{i}(isoCount,2) = isoStatesInterval{i}(j,2);
                    isoCount = isoCount + 1;
                end
            end
        end
    end
end

if isequal(isolateChecked, 1) && (isempty(stateTargetInterval{1}) || isempty(stateTargetInterval{2})) % Check to see if states were found in interval
    uiwait(errordlg('Chosen states do not exist in the defined interval.',...
             'ERROR','modal'));
else
    fid = fopen(['C:\Sleepdata\BSA\BSA_Rat' num2str(ratNumber) 'TT' num2str(tetrodeNumber) 'Date' num2str(expDate)...
        'I1_' num2str(startInterval(1)) '-' num2str(stopInterval(1)) 'I2_' num2str(startInterval(2)) '-' num2str(stopInterval(2)) '.xls'],'a');
    fprintf(fid,'Rat\t'); fprintf(fid,'%f\n', ratNumber);
    fprintf(fid,'Tetrode\t'); fprintf(fid,'%f\n', tetrodeNumber);
    fprintf(fid,'Date\t'); fprintf(fid,'%f\n\n', expDate);

    for cellNumber = 1:numberOfCells
        fprintf(fid,'Cell\t'); fprintf(fid,'%f\n', cellNumber);
        fprintf(fid,'BurstSize\t'); fprintf(fid,'Wire1\t'); fprintf(fid,'Wire2\t'); fprintf(fid,'Wire3\t'); fprintf(fid,'Wire4\n');
        %xlsHeader2 = {['Cell' num2str(cellNumber)], 'Tetrode', 'Date', 'IntervalStart (s)', 'IntervalStop (s)'};
        if cellNumber > 1
            filename = strrep(filename, ['C' num2str(cellNumber-1)], ['C' num2str(cellNumber)]);
        end
        for j = 1:2
            fid2 = fopen(filename{j});
            if isequal(fid2, -1)
                meanLastFirstRatio{j}(1,:) = zeros(1, 4);
                stdLastFirstRatio{j}(1,:) = zeros(1, 4);
                standardErrorLastFirstRatio{j}(1,:) = zeros(1, 4);
                sampleSize{j}(1) = 0;
            else
                try
                    [A, Astring] = xlsread(filename{j}); 
                catch %#ok<*CTCH>
                    uiwait(errordlg('Check if the file is saved in Microsoft Excel format.',...
                     'ERROR','modal'));
                end
                if strncmp(Astring(2,1), 'Burst Interval:', 9)
                    burstInterval = Astring{2,2};
                else
                    burstInterval = 'NotRecorded';
                end
                [lengthA,~] = size(A);
                indexB = 1;
                for i=5:lengthA
                    if isnan(A(i,3))
                    else
                        B(indexB,1:6) = [A(i,3:4) A(i,8:6:26)]; %#ok<*AGROW>
                        indexB = indexB+1;
                    end
                end


                %__________________________________________________________________
                interval = find(B(:,2) > startInterval(j) & B(:,2) < stopInterval(j)); 
                if isempty(interval)
                    meanLastFirstRatio{j}(1,:) = zeros(1, 4);
                    stdLastFirstRatio{j}(1,:) = zeros(1, 4);
                    standardErrorLastFirstRatio{j}(1,:) = zeros(1, 4);
                    sampleSize{j}(1) = 0;
                else
                    intervalB = B(interval,:); 
                    [lengthIntervalB, ~] = size(intervalB);
                    clear A B interval
                    %See if isolation of states for attenuation analysis is needed:
                    if isequal(isolateChecked, 1)
                        isoByStates = [];
                        [lengthIsoArray, ~] = size(stateTargetInterval{j});
                        for m = 1:lengthIsoArray % Extract all of the sub-intervals for states containing spikes.
                           subIntervalIndx = find(intervalB(:,2) >= stateTargetInterval{j}(m,1) & intervalB(:,2) <= stateTargetInterval{j}(m,2));
                           if isempty(subIntervalIndx)
                           else
                               isoByStates = [isoByStates; intervalB(subIntervalIndx,:)]; %#ok<AGROW>
                           end
                        end
                        intervalB = isoByStates;
                        [lengthIntervalB, ~] = size(intervalB);
                        clear isoByStates
                    end
                    if isempty(intervalB)  % Make sure that there are spikes in the defined subintervals.
                        meanLastFirstRatio{j}(1,:) = zeros(1, 4);
                        stdLastFirstRatio{j}(1,:) = zeros(1, 4);
                        standardErrorLastFirstRatio{j}(1,:) = zeros(1, 4);
                        sampleSize{j}(1) = 0;
                    else
                        maxBurst = max(intervalB(:,1));
                        for k = 2:maxBurst
                            %lastFirstRatios = [];
                            indexBursts = 1;
                            lastFirstRatios{j,k-1} = [];
                            for m = 1:lengthIntervalB
                                if isequal(intervalB(m,1), k)
                                    lastFirstRatios{j,k-1}(indexBursts,1:4) = intervalB(m,3:6);
                                    indexBursts = indexBursts + 1;
                                end
                            end
                            if isempty(lastFirstRatios{j,k-1}) || (indexBursts < 3)
                                meanLastFirstRatio{j}(k-1,:) = zeros(1, 4);
                                stdLastFirstRatio{j}(k-1,:) = zeros(1, 4);
                                standardErrorLastFirstRatio{j}(k-1,:) = zeros(1, 4);
                                sampleSize{j}(k-1) = 0;
                            else
                                meanLastFirstRatio{j}(k-1,:) = mean(lastFirstRatios{j,k-1});
                                stdLastFirstRatio{j}(k-1,:) = std(lastFirstRatios{j,k-1});
                                standardErrorLastFirstRatio{j}(k-1,:) = stdLastFirstRatio{j}(k-1,:)/sqrt(indexBursts - 2);
                                sampleSize{j}(k-1) = indexBursts - 1;
                            end
                        end
                    end
                end
            end
        end
        
        % Anna's in between output:
        selectedStates = '';
        for j = 1:8
            if isequal(isolatedStates(j),1)
              switch j
                  case 1
                      selectedStates = [selectedStates 'AW-'];
                  case 2
                      selectedStates = [selectedStates 'QW-'];
                  case 3
                      selectedStates = [selectedStates 'QS-'];
                  case 4
                      selectedStates = [selectedStates 'TR-'];
                  case 5
                      selectedStates = [selectedStates 'RE-'];
                  case 6
                      selectedStates = [selectedStates 'UH-'];
                  case 7
                      selectedStates = [selectedStates 'U1-'];
                  case 8
                      selectedStates = [selectedStates 'U2'];
              end
            end
        end
        
        midFileName = ['Rat' num2str(ratNumber) 'Cell' num2str(cellNumber) '_' selectedStates 'Last-FirstRatioArrays.mat'];
        save(midFileName, 'lastFirstRatios', 'burstInterval');
        % Now compute t-tests to determine if there is a difference between the two
        % intervals
        [x1,~]=size(meanLastFirstRatio{1,1});
        [x2,~]=size(meanLastFirstRatio{1,2});
        fprintf(fid,'Interval 1\n\t');
        fprintf(fid,'Mean Last-First Ratio\t\t\t\t');fprintf(fid,'Standard Error\n');
        for i = 1:x1
            fprintf(fid,'%f\t',(i+1));
            fprintf(fid,'%f\t %f\t %f\t %f\t',meanLastFirstRatio{1,1}(i,1:4));
            fprintf(fid,'%f\t %f\t %f\t %f\n',standardErrorLastFirstRatio{1,1}(i,1:4));
        end
        fprintf(fid,'Interval 2\n');
        fprintf(fid,'Mean Last-First Ratio\t\t\t\t');fprintf(fid,'Standard Error\n');
        for i = 1:x2
            fprintf(fid,'%f\t',(i+1));
            fprintf(fid,'%f\t %f\t %f\t %f\t',meanLastFirstRatio{1,2}(i,1:4));
            fprintf(fid,'%f\t %f\t %f\t %f\n',standardErrorLastFirstRatio{1,2}(i,1:4));
        end
        fprintf(fid,'t-Test p-values\n');
        fprintf(fid,'BurstSize\t'); fprintf(fid,'Wire1\t'); fprintf(fid,'Wire2\t'); fprintf(fid,'Wire3\t'); fprintf(fid,'Wire4\n');
        minNumberBursts = min([x1 x2]);
        zerosTest = zeros(1,4);
        indexTest = 1;
        for i = 1:minNumberBursts
            if isequal(zerosTest, meanLastFirstRatio{1}(i,:)) || isequal(zerosTest, meanLastFirstRatio{2}(i,:))
            else
                tTest4Attenuation(indexTest,1) = i+1;
                indexTest = indexTest + 1;
                for j = 1:4
                    [~,p] = ttest2(lastFirstRatios{1,i}(:,j), lastFirstRatios{2,i}(:,j));
                    tTest4Attenuation(i,j+1) = p;
                end
                fprintf(fid,'%f\t %f\t %f\t %f\t %f\n', tTest4Attenuation(i,:));
            end 
        end
        clear meanLastFirstRatio standardErrorLastFirstRatio lastFirstRatios tTest4Attenuation
    end
    fclose(fid);
end


