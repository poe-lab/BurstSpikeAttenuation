function attenuationStatisticsAtLeast3Spikes_01152018
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
comboVector = [bursts.cellIdentity bursts.lapNum];
comboVector = comboVector(bursts.numSpikes>=3, :);
lastTo1stAmpRatio = bursts.lastTo1stAmpRatio(bursts.numSpikes>=3);
maxAmp = bursts.maxAmp(bursts.numSpikes>=3);
uniqueCombos = unique(comboVector, 'rows'); % Vector for unique sets
numOfCombos = size(uniqueCombos, 1); % Finds the number of sets in the data
meanMaxAmp = zeros(numOfCombos, 1);
stdMaxAmp = meanMaxAmp;
meanLast1stRatio = zeros(numOfCombos, 1); %meanMaxAmp;
stdLast1stRatio = meanLast1stRatio; %meanMaxAmp;
sampleSizeCombo = zeros(numOfCombos, 1);

for i = 1:numOfCombos
    logicTarget = ismember(comboVector, uniqueCombos(i,:), 'rows');
    sampleSizeCombo(i) = sum(logicTarget);
    meanMaxAmp(i) = mean(maxAmp(logicTarget),1);
    stdMaxAmp(i) = std(maxAmp(logicTarget),0,1);
    meanLast1stRatio(i,:) = mean(lastTo1stAmpRatio(logicTarget),1);
    stdLast1stRatio(i,:) = std(lastTo1stAmpRatio(logicTarget),0,1);    
end

%% Identify unique cells and number of them:
comboVector = uniqueCombos;
clear uniqueCombos

cellByLap.meanMaxAmp = meanMaxAmp;
cellByLap.stdMaxAmp = stdMaxAmp;
cellByLap.meanLast1st = meanLast1stRatio;
cellByLap.StdDevLast1st = stdLast1stRatio;
cellByLap.numSamples = sampleSizeCombo;
cellByLap.cellLapId = comboVector;

uniqueLaps = unique(comboVector(:,3));
numLaps = size(uniqueLaps, 1);
allCellsByLap.meanLast1st = zeros(numLaps,1); 
allCellsByLap.stdDevLast1st = allCellsByLap.meanLast1st; 
allCellsByLap.meanMaxAmp = zeros(numLaps,1); 
allCellsByLap.stdDevMaxAmp = allCellsByLap.meanMaxAmp; 
allCellsByLap.numSamples = zeros(numLaps, 1);
for i = 1:numLaps
    logicTarget = ismember(comboVector(:,3), uniqueLaps(i));
    allCellsByLap.numSamples(i) = sum(logicTarget);
    allCellsByLap.meanLast1st(i) = mean(cellByLap.meanLast1st(logicTarget),1);
    allCellsByLap.stdDevLast1st(i) = std(cellByLap.meanLast1st(logicTarget),0,1);
    allCellsByLap.meanMaxAmp(i) = mean(cellByLap.meanMaxAmp(logicTarget),1);
    allCellsByLap.stdDevMaxAmp(i) = std(cellByLap.meanMaxAmp(logicTarget),0,1);
end
allCellsByLap.lapNum = uniqueLaps;

%% Run analyses for the Familiar maze:
first5 = 1:1:5;
last5 = 11:1:15;
famMazeLast1st = compareLapSets_01152018(meanLast1stRatio, comboVector, first5, last5);
famMazeMaxAmp = compareLapSets_01152018(meanMaxAmp, comboVector, first5, last5);

%% Run analyses for the Reversal maze:
first5 = 16:1:20;
last5 = 26:1:30;
revMazeLast1st = compareLapSets_01152018(meanLast1stRatio, comboVector, first5, last5);
revMazeMaxAmp = compareLapSets_01152018(meanMaxAmp, comboVector, first5, last5);

%% Save attenuation results to .MAT file:
matFile = strrep(burstFileName, '.mat', '_AttenAtLeast3Spikes.mat');
save(matFile, 'burstFile', 'cellByLap', 'allCellsByLap', 'famMazeLast1st', 'famMazeMaxAmp', 'revMazeLast1st', 'revMazeMaxAmp');