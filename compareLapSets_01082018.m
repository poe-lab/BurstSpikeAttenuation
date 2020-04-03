function results = compareLapSets_01082018(meanLast1stRatio, comboVector, set1, set2)
uniqueCombos = unique(comboVector(:,1:2), 'rows'); % Vector for unique sets
numOfCombos = size(uniqueCombos, 1); % Finds the number of sets in the data
Set1_meanLast1stRatio = zeros(numOfCombos, 4);
Set2_meanLast1stRatio = zeros(numOfCombos, 4);
sampleSizeCombo = zeros(numOfCombos, 2);
results.set1 = set1;
results.set2 = set2;

for i = 1:numOfCombos
    % Calculate average ratio for first set of laps:
    logicTarget = ismember(comboVector(:,1:2), uniqueCombos(i,:), 'rows') & ismember(comboVector(:,3), set1);
    sampleSizeCombo(i,1) = sum(logicTarget);
    if sampleSizeCombo(i,1) ~= 0
        Set1_meanLast1stRatio(i,:) = mean(meanLast1stRatio(logicTarget,:),1);
    end
    % Calculate average ratio for second set of laps:
    logicTarget = ismember(comboVector(:,1:2), uniqueCombos(i,:), 'rows') & ismember(comboVector(:,3), set2);
    sampleSizeCombo(i,2) = sum(logicTarget);
    if sampleSizeCombo(i,2) ~= 0
        Set2_meanLast1stRatio(i,:) = mean(meanLast1stRatio(logicTarget,:),1);
    end
end

%% Keep only cells that have values in both sets of laps:
logicTarget = sampleSizeCombo(:,1) ~= 0 & sampleSizeCombo(:,2) ~= 0;
if sum(logicTarget) ~=0
    results.cellIdentity = uniqueCombos(logicTarget,:);
    results.Set1_meanLast1stRatio = Set1_meanLast1stRatio(logicTarget,:);
    results.Set2_meanLast1stRatio = Set2_meanLast1stRatio(logicTarget,:);
    results.sampleSizeCombo = sampleSizeCombo(logicTarget,:);
    if sum(logicTarget) >=  6
        for i = 1:4
        [~,results.tTestP(i)] = ttest(Set1_meanLast1stRatio(:,i), Set2_meanLast1stRatio(:,i));
        end
    end
else
    results = [];
end
end