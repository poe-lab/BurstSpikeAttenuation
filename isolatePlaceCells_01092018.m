function isolatePlaceCells_01092018(placeCells)

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

%% Remove all non-place cells:
cellIdentity = [bursts.tetrodeNumber bursts.cellNumber];
notPlaceCell = ~ismember(cellIdentity, placeCells, 'rows');
bursts.startTime(notPlaceCell) = [];
bursts.duration(notPlaceCell) = [];
bursts.cellNumber(notPlaceCell) = [];
bursts.tetrodeNumber(notPlaceCell) = [];
bursts.numSpikes(notPlaceCell) = [];
bursts.maxAmp(notPlaceCell,:) = [];
bursts.lastTo1stAmpRatio(notPlaceCell,:) = [];
bursts.lapNum(notPlaceCell) = [];
%% Save new spike burst data isolated by place cells to .MAT file:
matFile = strrep(burstFileName, '.mat', '_placeCells.mat');
save(matFile, 'lapFile', 'burstFile', 'bursts', 'numLaps', 'placeCells');