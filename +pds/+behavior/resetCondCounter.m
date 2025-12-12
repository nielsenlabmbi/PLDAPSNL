function p = resetCondCounter(p,counterNames)

for i=1:length(counterNames)
    p.trialMem.stats.condCounter{i}=zeros(4,length(counterNames{i}));
    p.trialMem.stats.condCounterNames{i}=counterNames{i};
end

disp('Reset counter')