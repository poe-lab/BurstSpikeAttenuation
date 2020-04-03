function burstSpikeOption2_12112017(BSInterval)
% Burst Spikes Attenuation Analysis Option 2
%--Uses NTT files and combines all spikes for a burst
%--Lists all cells in a burst
%--Lists burst length
%--Lists number of spikes in each burst
%% Load NTT files
% Select folder and get list of NTT files:
fileType = '*.ntt';
[dataFolder, fileList, numberOfDataFiles] = batchLoadFiles(fileType);

%% Load Time Stamp File
% Prompt user to select the time stamp file:
working_dir=pwd;
current_dir='C:\SleepData';
cd(current_dir);
[filename, pathname] = uigetfile('*.xls', 'Pick the timestamp file for these datafiles');
if isequal(filename,0) || isequal(pathname,0)
    uiwait(errordlg('You need to select a file. Please press the button again',...
        'ERROR','modal'));
    cd(working_dir);
else
    cd(working_dir);
    timestampfile= fullfile(pathname, filename);
end
clear filename pathname

% *********** Timestamps extraction *********
waithandle= waitbar(0.2,'Finding Timestamp Ranges ..... ');pause(0.2);
% filename = get(handles.tstampsfile,'TooltipString');
try
    timestampSections = xlsread(timestampfile);
catch
    uiwait(errordlg('Check if the file is saved in Microsoft Excel format.',...
        'ERROR','modal'));
end
close(waithandle);
timeRange = [timestampSections(1,5) timestampSections(end,6)];
clear timestampSections

%% Load and combibe all spike data from NTT files
% The FOR loop below extracts unit number, time stamp data from NTT files one at a time
allTetrodes.timeStamps = [];
allTetrodes.cellNumber = [];
allTetrodes.tetrodeNumber = [];
totalNumUnits = 0;

for i = 1:numberOfDataFiles
    fileName = strtrim(fileList(i,:)); %Removes any white space at end of file name string.
    tetrodeFile = fullfile(dataFolder,fileName); %Full file path for Neuralynx file to be loaded
    % Import the data:
    
    % Set up variable for sorted Neuralynx NTT file:
    waithandle= waitbar(0.2,['Loading spikes from ' fileName]);pause(0.2);
    [spike.Timestamp, spike.CellNumber] = Nlx2MatSpike(tetrodeFile, [1 0 1 0 0], 0, 4, timeRange);
    nonZerosIndex = find(spike.CellNumber);
    spike.CellNumber = spike.CellNumber(nonZerosIndex);
    spike.Timestamp = spike.Timestamp(nonZerosIndex);
    clear nonZerosIndex
    totalNumUnits = totalNumUnits + size(unique(spike.CellNumber),2); %Assumes 1xn vector
    spike.Timestamp = spike.Timestamp/1000000;
    allTetrodes.tetrodeNumber = [allTetrodes.tetrodeNumber; i*ones(length(spike.Timestamp),1)];
    allTetrodes.timeStamps = [allTetrodes.timeStamps; spike.Timestamp'];
    clear spike.Timestamp
    allTetrodes.cellNumber = [allTetrodes.cellNumber; spike.CellNumber'];
    clear spike.CellNumber
    close(waithandle);
end

%% Sort all spike data by time stamp
[allTetrodes.timeStamps, IX] = sort(allTetrodes.timeStamps,1);
allTetrodes.tetrodeNumber = allTetrodes.tetrodeNumber(IX);
allTetrodes.cellNumber = allTetrodes.cellNumber(IX);
clear IX

%% Assign scored stages to the data if present
% Question box for adding another EEG signal:
addScoredChoice = questdlg('Would you like to analyze with respect to scored stages?',...
            'Attenuation Analysis by Stage', 'Yes', 'No','No');
% If the user chooses 'Yes', this box appears to select the stage scored file:
switch addScoredChoice
    case 'Yes'
        labelCheck = 0;
        while isequal(labelCheck, 0)
            allTetrodes.states = labelSpikeStates(spikeTimeStamps);
            if isequal(unique(allTetrodes.states), 0)
                
                retryScoredChoice = questdlg('No spikes were labeled. Try loading another file or continue without considering stages?',...
                'Attenuation Analysis by Stage', 'Yes', 'No','No');
                switch addScoredChoice
                    case 'Yes'
                        labelCheck = 0;
                    case 'No'
                        labelCheck = 1;
                        allTetrodes.states = [];
                end
            else
                labelCheck = 1;
            end
        end
    case 'No'
        allTetrodes.states = [];
        waithandle= waitbar(0.2,'Continuing analysis without considering stages.');pause(0.2);
end


%% Run Burst Analysis
%First run without considering stages or individual cells:
% 'burstsAC'--> spike bursts for all cells grouped together
burstsAC = findSpikeBursts(allTetrodes.timeStamps);
if isempty(burstsAC)
    uiwait(errordlg('No spike bursts were found based on the chosen burst interval.',...
        'ERROR','modal'));
    return
else
    burstPropsAC = burstProperties(burstsAC, allTetrodes);
end


function burstGroup = findSpikeBursts(varargin)

if nargin == 2
  spikeTimes = varargin{1}(:);
  cellNumber = varargin{2}(:); 
else
  spikeTimes = varargin{1}(:);
  cellNumber = ones(size(spikeTimes,1),2); 
end


uniqueCells = unique(cellNumber, 'rows'); % Vector for unique cells
numOfCells = size(uniqueCells, 1); % Finds the number of cells in the data

%% Find Spike Bursts
burstGroup = [];
for m = 1:numOfCells
    %Find all spikes for matching unit:
    logicMatchCell = ismember(cellNumber, uniqueCells(m), 'rows');
    cellData = spikeTimes(logicMatchCell); %Isolate spikes of target cell
    if isempty(cellData)
    else
        numericMatchCell = +logicMatchCell; %Convert logical result to number
        originalSpikeIdx = find(numericMatchCell); %Preserve original spike index
        cellRow = size(cellData,1); %Find # of spikes of the target cell
        timeDifference = diff(cellData);
        logicPassInterval = timeDifference < BSInterval;
        if isempty(logicPassInterval)
        else
            groupNumber = 1;
            if logicPassInterval(1)
                burstGroup{m,1} = originalSpikeIdx(1);
            end
            for n = 2:cellRow-1
                if logicPassInterval(n)
                    burstGroup{m,groupNumber} = [burstGroup{m,groupNumber} originalSpikeIdx(n)];
                elseif logicPassInterval(n-1)
                    burstGroup{m,groupNumber} = [burstGroup{m,groupNumber} originalSpikeIdx(n)];
                    groupNumber = groupNumber+1;                
                end
            end

        end
    end
end


function burstProps = burstProperties(burstData, allTetrodes)
[numCats, numOfBursts] =  size(burstData);
for m = 1:numCats
    for n = 1:numOfBursts
           burstProps.cellsInBurst{m,n} = [allTetrodes.tetrodeNumber(burstData{m,n})...
               allTetrodes.cellNumber(burstData{m,n})];
           burstProps.numUniqueCells{m}(n) = size(unique(burstProps.cellsInBurst{m,n}, 'rows'), 1);
           burstProps.burstLength{m}(n) = length(burstData{m,n});
           burstProps.burstTime{m}(n) = allTetrodes.timeStamps(burstData{m,n}(burstProps.burstLength{m}(n)))...
               - allTetrodes.timeStamps(burstData{m,n}(1));
           burstProps.burstFreq{m}(n) = burstProps.burstLength{m}(n)/burstProps.burstTime{m}(n);

    end
end






