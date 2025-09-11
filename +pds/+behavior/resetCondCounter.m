function p = resetCondCounter(p,counterNames)

p.trialMem.stats.condCounter=zeros(3,length(counterNames));
p.trialMem.stats.condCounterNames=counterNames;