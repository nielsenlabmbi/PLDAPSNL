function p=countTrialNew(p,respCorr,countCond,varargin)

%increment counters for the trial
%input: 
% p - pldaps
% respCorr: 1 - correct trial
% countCond: count only sides (0) or sides and conditions (1)
% varargin: cond index for cond counter (if different from what is in
% p.conditions)
%


currCond=p.conditions{p.trial.pldaps.iTrial};

%increment side counters
%total number trials
p.trialMem.stats.sideCounter(1,currCond.side)=p.trialMem.stats.sideCounter(1,currCond.side)+1;
%correct/incorrect
if respCorr==1
    p.trialMem.stats.sideCounter(2,currCond.side)=p.trialMem.stats.sideCounter(2,currCond.side)+1;
else
    p.trialMem.stats.sideCounter(3,currCond.side)=p.trialMem.stats.sideCounter(3,currCond.side)+1;
end

%increment condition counters
if countCond==1
    if nargin==3 %no varargin
        condIdx=currCond.condIdx;
    else
        condIdx=varargin{1};
    end
    p.trialMem.stats.condCounter(1,condIdx)=p.trialMem.stats.condCounter(1,condIdx)+1;
    %correct/incorrect
    if respCorr==1
        p.trialMem.stats.condCounter(2,condIdx)=p.trialMem.stats.condCounter(2,condIdx)+1;
    else
        p.trialMem.stats.condCounter(3,condIdx)=p.trialMem.stats.condCounter(3,condIdx)+1;
    end
end
