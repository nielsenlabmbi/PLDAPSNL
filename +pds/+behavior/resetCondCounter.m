function p = resetCondCounter(p,counterNames,counterIdx)

p.trialMem.stats.condCounter=zeros(4,length(counterNames{counterIdx}));
p.trialMem.stats.condCounterNames=counterNames{counterIdx};
disp('Reset counter')