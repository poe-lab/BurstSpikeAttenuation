function saveBurstsToNTT_01162018
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
  BSInterval = 0.01; % time in seconds; up to 10 milliseconds allowed between spikes
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
    %% Load the .ntt file:    
    [spikeTimes, tetrodeNum, cellNumber, features, Samples, Header] =...
        Nlx2MatSpike(tetrodeFile, [1 1 1 1 1], 1, 1, [] );
    %% Remove unsorted spikes:
    nonZerosIndex = find(cellNumber);       % Identify spikes with a unit assignment
    Samples = Samples(:, :, nonZerosIndex);   % Remove amplitudes of unsorted spikes
    cellNumber = cellNumber(nonZerosIndex); % Remove cell # unsorted spikes
    spikeTimes = spikeTimes(nonZerosIndex);   % Remove time stamps of unsorted spikes
    tetrodeNum = tetrodeNum(nonZerosIndex);   % Remove tetrode # of unsorted spikes
    features =features(:, nonZerosIndex);   % Remove features of unsorted spikes
    clear nonZerosIndex
    
    %% Find Spike Bursts for each cell:
    uniqueCells = unique(cellNumber); % Vector for unique cells
    numOfCells = size(uniqueCells, 2); % Finds the number of cells in the data
    isolateSpikes = [];
    for m = 1:numOfCells
        %Find all spikes for matching unit:
        spikeIdx = find(cellNumber == uniqueCells(m));
        cellSpikeTS = spikeTimes(spikeIdx); %Isolate spikes times of target cell

%         %% Remove the current cell data from grouped data for efficiency:
%         cellNumber = cellNumber(~logicMatchCell); % Remove cell # from grouped data
%         spikeTimes = spikeTimes(~logicMatchCell);   % Remove spike times from grouped data
%         peakAmp = peakAmp(~logicMatchCell, :);  % Remove amplitudes from grouped data

        %% Find the beginning and end of each burst
        diffTime = diff(cellSpikeTS) <= (BSInterval*1000000);
        lengthSignal = size(cellSpikeTS,2);
        startBurst = find(diff(diffTime) == 1) + 1;
        endBurst = find(diff(diffTime) == -1) + 1;
        if isempty(startBurst) || isempty(endBurst)
        else
            if endBurst(1) < startBurst(1)	% Corrects for bursts that start at the beginning of the data
                startBurst = [1 startBurst];  
            end
            if startBurst(end) > endBurst(end)	% Corrects for bursts that end at the end of the data
                endBurst = [endBurst lengthSignal];
            end
            
            
            spikeOfBurstsIdx = find((endBurst-startBurst+1) >= 3);
            startBurst = startBurst(spikeOfBurstsIdx);
            endBurst = endBurst(spikeOfBurstsIdx);
            
            %% Calculate output data for each burst:
            numBursts = size(startBurst,2); %Find # of bursts of the target cell
            keepSpikes = [];
            for n = 1:numBursts
                keepSpikes = [keepSpikes startBurst(n):1:endBurst(n)];
            end
            isolateSpikes = [isolateSpikes spikeIdx(keepSpikes)];
        end
    end
%% Sort indices of spikes from all of the cells:
isolateSpikes = sort(isolateSpikes);

%% Keep data for the isolated spikes:
Samples = Samples(:, :, isolateSpikes);
cellNumber = cellNumber(isolateSpikes);
spikeTimes = spikeTimes(isolateSpikes);
tetrodeNum = tetrodeNum(isolateSpikes);
features =features(:, isolateSpikes);

%% Write data with only spikes in bursts to a new .ntt file:
newNttFile = fullfile(dataFolder, ['spikesOfBursts_' fileName]); %Full file path for new .ntt
Mat2NlxSpike(newNttFile, 0, 1, [], [1 1 1 1 1 1], spikeTimes, tetrodeNum,...
    cellNumber, features, Samples, Header);

end




end   
