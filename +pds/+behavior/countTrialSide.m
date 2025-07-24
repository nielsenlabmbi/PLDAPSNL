function p=countTrialSide(p,respCorr)

%maintain separate counter for sides (for experiments with lots of conditions)
%input: respCorr=1: correct

if p.trial.side==p.trial.stimulus.side.LEFT
    p.trialMem.stats.count.Nleft=p.trialMem.stats.count.Nleft+1;
    if respCorr==1
        p.trialMem.stats.count.NleftCorr=p.trialMem.stats.count.NleftCorr+1;
    end
else
    p.trialMem.stats.count.Nright=p.trialMem.stats.count.Nright+1;
    if respCorr==1
        p.trialMem.stats.count.NrightCorr=p.trialMem.stats.count.NrightCorr+1;
    end
end
