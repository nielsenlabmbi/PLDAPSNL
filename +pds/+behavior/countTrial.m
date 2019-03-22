function p=countTrial(p,respCorr)

%increment counters for the trial
%input: p - pldaps
% respCorr: 1 - correct trial

nCond=size(p.trialMem.stats.val,2);
if p.trial.userInput == -1;
    whichConditions = mod(p.trialMem.whichConditions-1,length(p.trial.allconditions));
    currCond = p.trial.allconditions{whichConditions + 1}{p.trial.pldaps.iTrial};
else
    currCond=p.conditions{p.trial.pldaps.iTrial};
end

%determine index for trial condition
condIdx=[1:nCond];
for i=1:length(p.trialMem.stats.cond) %loop through the parameters that are used for bookkeeping
    pval=currCond.(p.trialMem.stats.cond{i}); %parameter for current trial
    idx=find(p.trialMem.stats.val(i,:)==pval); %determine matching bookkeeping conditions 
    condIdx=intersect(condIdx,idx); %this will shrink the selection down to the shared conditions 
end


%now increment counters
if ~isempty(condIdx)
    p.trialMem.stats.count.Ntrial(condIdx)=p.trialMem.stats.count.Ntrial(condIdx)+1;
    if respCorr==1
        p.trialMem.stats.count.correct(condIdx)=p.trialMem.stats.count.correct(condIdx)+1;
    else
        p.trialMem.stats.count.incorrect(condIdx)=p.trialMem.stats.count.incorrect(condIdx)+1;
    end
end