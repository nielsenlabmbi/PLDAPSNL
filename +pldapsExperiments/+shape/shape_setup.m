function p=shape_setup(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.shape.shape_trial';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.defaultParameters.stimulus.duration.ITI; %ITI in s


%% conditions:

%different from usual arrangement - there are always 2 shapes on the
%screen, but only one is rewarded

%pseudorandomization
basicSide=[1 1 1 1 1 2 2 2 2 2];
cond.side=zeros(1,500);
for i=1:50
    cond.side((i-1)*10+1:i*10)=basicSide(randperm(10));
end
c{1}=cond;
p.trial.allconditions = c;
p.trialMem.whichConditions = 0;
p.conditions=p.trial.allconditions{p.trialMem.whichConditions + 1};

p.trial.pldaps.finish = length(p.conditions);



%% display stats
%p.trialMem.stats.cond={'side'}; %conditions to display
[A,B,C] = ndgrid(unique(horzcat(cond.angle)),unique(horzcat(cond.sf)),unique(horzcat(cond.range)));
%p.trialMem.stats.val = [A(:),B(:),C(:)]';
%nCond=size(p.trialMem.stats.val,2);
%p.trialMem.stats.count.correct=zeros(1,nCond);
%p.trialMem.stats.count.incorrect=zeros(1,nCond);
%p.trialMem.stats.count.Ntrial=zeros(1,nCond);