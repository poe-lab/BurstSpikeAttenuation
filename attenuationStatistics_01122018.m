function attenuationStatistics_01122018
% Customize this function to perform the desired statistical analyses for
% attenuation of spike bursts across laps or days.

%% Load the .MAT file with spike bursts by lap for only place cells:
working_dir=pwd;
current_dir='C:\';
cd(current_dir);

[burstFile, burstPath] = uigetfile({'*.mat',...
        'Spike bursts by lap file (*.MAT)'},'Select spike burst by lap data:');
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

%% Isolate spike bursts with only 3 spikes:
comboVector = [bursts.tetrodeNumber bursts.cellNumber bursts.lapNum];
comboVector = comboVector(bursts.numSpikes==3, :);
lastTo1stAmpRatio = bursts.lastTo1stAmpRatio(bursts.numSpikes==3, :);
uniqueCombos = unique(comboVector, 'rows'); % Vector for unique sets
numOfCombos = size(uniqueCombos, 1); % Finds the number of sets in the data
% meanMaxAmp = zeros(numOfCombos, 4);
% stdMaxAmp = meanMaxAmp;
meanLast1stRatio = zeros(numOfCombos, 4); %meanMaxAmp;
stdLast1stRatio = meanLast1stRatio; %meanMaxAmp;
sampleSizeCombo = zeros(numOfCombos, 1);

for i = 1:numOfCombos
    logicTarget = ismember(comboVector, uniqueCombos(i,:), 'rows');
    sampleSizeCombo(i) = sum(logicTarget);
%     meanMaxAmp(i,:) = mean(bursts.maxAmp(logicTarget,:));
%     stdMaxAmp(i,:) = std(bursts.maxAmp(logicTarget,:));
    meanLast1stRatio(i,:) = mean(lastTo1stAmpRatio(logicTarget,:),1);
    stdLast1stRatio(i,:) = std(lastTo1stAmpRatio(logicTarget,:),0,1);    
end

%% Identify unique cells and number of them:
comboVector = uniqueCombos;
clear uniqueCombos

cellByLap.mean = meanLast1stRatio;
cellByLap.StdDev = stdLast1stRatio;
cellByLap.numSamples = sampleSizeCombo;
cellByLap.cellLapId = comboVector;

uniqueLaps = unique(comboVector(:,3));
numLaps = size(uniqueLaps, 1);
allCellsByLap.mean = zeros(numLaps, 4); %meanMaxAmp;
allCellsByLap.stdDev = allCellsByLap.mean; %meanMaxAmp;
allCellsByLap.numSamples = zeros(numLaps, 1);
for i = 1:numLaps
    logicTarget = ismember(comboVector(:,3), uniqueLaps(i));
    allCellsByLap.numSamples(i) = sum(logicTarget);
    allCellsByLap.mean(i,:) = mean(cellByLap.mean(logicTarget,:),1);
    allCellsByLap.stdDev(i,:) = std(cellByLap.mean(logicTarget,:),0,1);
end
allCellsByLap.lapNum = uniqueLaps;

%% Run analyses for the Familiar maze:
first5 = 1:1:5;
last5 = 11:1:15;
famMaze = compareLapSets_01082018(meanLast1stRatio, comboVector, first5, last5);

%% Run analyses for the Reversal maze:
first5 = 16:1:20;
last5 = 26:1:30;
revMaze = compareLapSets_01082018(meanLast1stRatio, comboVector, first5, last5);

%% Save attenuation results to .MAT file:
matFile = strrep(burstFileName, '.mat', '_Atten.mat');
save(matFile, 'burstFile', 'cellByLap', 'allCellsByLap', 'famMaze', 'revMaze');