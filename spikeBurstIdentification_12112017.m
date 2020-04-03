function spikeBurstIdentification_12112017(varargin)
% Identifies spike bursts for each cell in all tetrodes within the selected
% folder.
%--INPUT: NTT files in the selected folder
%--OUTPUT: .MAT file containing: Tetrode #, Unit # of tetrode, time of 1st
%spike in burst, time of last spike in burst, number of spikes in burst,
%and info for each wire (peak amp of 1st spike, peak amp of last spike, max
%amp, last to first amp ratio)

%% Define max difference in time between spikes to include in same burst:
if nargin == 1
  BSInterval = varargin{1}(:);
else
  BSInterval = 0.01; % time in seconds
end


%% Load NTT files
% Select folder and get list of NTT files:
fileType = '*.ntt';
[dataFolder, fileList, numberOfDataFiles] = batchLoadFiles(fileType);

%% Load and combibe all spike data from NTT files
% The FOR loop below extracts unit number, time stamp data from NTT files one at a time
bursts.startTime = [];
bursts.duration = [];
bursts.cellNumber = [];
bursts.tetrodeNumber = [];
bursts.numSpikes = [];
bursts.maxAmp = [];
bursts.lastTo1stAmpRatio = [];

%% For each tetrode, load in the data and identify all bursts:
for i = 1:numberOfDataFiles
    fileName = strtrim(fileList(i,:)); %Removes any white space at end of file name string.
    tetrodeFile = fullfile(dataFolder,fileName); %Full file path for Neuralynx file to be loaded
    %% Import the data:
    % Set up variable for sorted Neuralynx NTT file:
%     waithandle= waitbar(0.2,['Loading spikes from ' fileName]);pause(0.2);
    [spikeTimes, tetrodeNum, cellNumber, Samples] = Nlx2MatSpike(tetrodeFile, [1 1 1 0 1], 0, 1, []); % Load only time stamps, cell #, and amplitudes
    %% Remove unsorted spikes:
    nonZerosIndex = find(cellNumber);       % Identify spikes with a unit assignment
    Samples = Samples(5:11, :, nonZerosIndex);   % Remove amplitudes of unsorted spikes
    cellNumber = cellNumber(nonZerosIndex)'; % Remove cell # unsorted spikes
    spikeTimes = spikeTimes(nonZerosIndex)' ./ 1000000;   % Remove time stamps of unsorted spikes and convert to seconds
    tetrodeNum = tetrodeNum(1) + 1;   % Reduce to just 1 value
    clear nonZerosIndex
    
    %% Determine the max amplitude/spike waveform/wire:
    peakAmp = max(Samples, [], 1);
    clear Samples
    peakAmp = squeeze(peakAmp);
    peakAmp = peakAmp';
    
    %% Find Spike Bursts for each cell:
    uniqueCells = unique(cellNumber, 'rows'); % Vector for unique cells
    numOfCells = size(uniqueCells, 1); % Finds the number of cells in the data
    
    for m = 1:numOfCells
        %Find all spikes for matching unit:
        logicMatchCell = ismember(cellNumber, uniqueCells(m), 'rows');
        cellSpikeTS = spikeTimes(logicMatchCell); %Isolate spikes times of target cell
        cellPkAmp = peakAmp(logicMatchCell, :); %Isolate peak amplitudes of target cell
        if isempty(cellSpikeTS)
        else
            %% Remove the current cell data from grouped data for efficiency:
            cellNumber = cellNumber(~logicMatchCell); % Remove cell # from grouped data
            spikeTimes = spikeTimes(~logicMatchCell);   % Remove spike times from grouped data
            peakAmp = peakAmp(~logicMatchCell, :);  % Remove amplitudes from grouped data
            
            %% Find the beginning and end of each burst
            diffTime = diff(cellSpikeTS) < BSInterval;
            lengthSignal = size(cellSpikeTS,1);
            startBurst = find(diff(diffTime) == 1) + 1;
            endBurst = find(diff(diffTime) == -1) + 1;
            if isempty(startBurst) || isempty(endBurst)
            else
                if endBurst(1) < startBurst(1)	% Corrects for bursts that start at the beginning of the data
                    startBurst = [1; startBurst];  
                end
                if startBurst(end) > endBurst(end)	% Corrects for bursts that end at the end of the data
                    endBurst = [endBurst; lengthSignal];
                end

                %% Calculate output data for each burst:
                numBursts = size(startBurst,1); %Find # of bursts of the target cell
                maxAmp = zeros(numBursts, 4);
                last2First = zeros(numBursts, 4);
                for n = 1:numBursts
                    maxAmp(n,:) = max(cellPkAmp(startBurst(n):endBurst(n), :), [], 1);
                    last2First(n,:) = cellPkAmp(endBurst(n), :) ./ cellPkAmp(startBurst(n), :);  
                end
                bursts.startTime = [bursts.startTime; cellSpikeTS(startBurst)];
                bursts.duration = [bursts.duration; (cellSpikeTS(endBurst) - cellSpikeTS(startBurst))];
                bursts.cellNumber = [bursts.cellNumber; uniqueCells(m)*ones(numBursts,1)];
                bursts.tetrodeNumber = [bursts.tetrodeNumber; tetrodeNum*ones(numBursts,1)];
                bursts.numSpikes = [bursts.numSpikes; endBurst-startBurst+1];
                bursts.maxAmp = [bursts.maxAmp; maxAmp];
                bursts.lastTo1stAmpRatio = [bursts.lastTo1stAmpRatio; last2First];
            end
        end
    end
end

%% Sort all spike data by time stamp
[bursts.startTime, IX] = sort(bursts.startTime,1);
bursts.duration = bursts.duration(IX);
bursts.cellNumber = bursts.cellNumber(IX);
bursts.tetrodeNumber =bursts.tetrodeNumber(IX);
bursts.numSpikes = bursts.numSpikes(IX);
bursts.maxAmp = bursts.maxAmp(IX, :);
bursts.lastTo1stAmpRatio = bursts.lastTo1stAmpRatio(IX, :);
clear IX

%% SAVE DATA AND FIGURE
%Request user to name output file:
prompt = {'Enter the filename you want to save it as: (just the name)'};
def = {'Rat#_Day'};
dlgTitle = 'Save .MAT file';
lineNo = 1;
answer = inputdlg(prompt,dlgTitle,lineNo,def);
filename = char(answer(1,:));
save(fullfile(dataFolder,['Bursts', filename, '.mat']), 'dataFolder', 'fileList', 'bursts');


