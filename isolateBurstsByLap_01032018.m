function isolateBurstsByLap_01032018
% Use this function to isolate data from SpikeBurstIdentification_DATE.m
% by the specified time bins for each lap/trial of a given task.

%% Load the .MAT file with spike bursts:
working_dir=pwd;
current_dir='C:\';
cd(current_dir);

[burstFile, burstPath] = uigetfile({'*.mat',...
        'Detected spike bursts file (*.MAT)'},'Select the spike burst data file:');
if isequal(burstFile,0) || isequal(burstPath,0)
    uiwait(errordlg('You need to select a file. Please try again',...
        'ERROR','modal'));
    cd(working_dir);
else
    cd(working_dir);
    burstFileName = fullfile(burstPath, burstFile);
end
load(burstFileName, '-mat')
clear burstPath

%% Load the .MAT file with lap times:
working_dir=pwd;
current_dir='C:\';
cd(current_dir);

[lapFile, lapPath] = uigetfile({'*.mat',...
        'Lap times file (*.MAT)'},'Select the lap times data file:');
if isequal(lapFile,0) || isequal(lapPath,0)
    uiwait(errordlg('You need to select a file. Please try again',...
        'ERROR','modal'));
    cd(working_dir);
else
    cd(working_dir);
    lapFileName = fullfile(lapPath, lapFile);
end
load(lapFileName, '-mat')
clear lapPath lapFileName

%% Label each spike burst by lap
lapNum = zeros(size(bursts.startTime));
numLaps = size(segmentTimeStamps, 2);

for i = 1:numLaps
    for j = 1:size(segmentTimeStamps{1,i},1)
        subIntervalIndx = find(bursts.startTime >= segmentTimeStamps{1,i}(j,1) & bursts.startTime <= segmentTimeStamps{1,i}(j,2));
        if ~isempty(subIntervalIndx)
            lapNum(subIntervalIndx) = i;
            clear subIntervalIndx
        end
    end
end

%% Remove all bursts not within any of the lap times:
notInLapTimes = find(lapNum == 0);
bursts.startTime(notInLapTimes) = [];
bursts.duration(notInLapTimes) = [];
bursts.cellNumber(notInLapTimes) = [];
bursts.tetrodeNumber(notInLapTimes) = [];
bursts.numSpikes(notInLapTimes) = [];
bursts.maxAmp(notInLapTimes,:) = [];
bursts.lastTo1stAmpRatio(notInLapTimes,:) = [];
bursts.lapNum = [];
bursts.lapNum = lapNum(lapNum ~= 0);

%% Save new spike burst data isolated by lap number to .MAT file:
matFile = strrep(burstFileName, '.mat', '_byLap.mat');
save(matFile, 'lapFile', 'burstFile', 'bursts', 'numLaps');
end



