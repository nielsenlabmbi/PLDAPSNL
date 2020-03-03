function p=ori_setup_free(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.ori.oritrial_free';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.defaultParameters.stimulus.duration.ITI; %ITI in s


%% conditions:
side.par = 'angle';
side.match = [90 0];
for i = 1:length(p.defaultParameters.stimulus.fullField)
    cond(i).sf = p.defaultParameters.stimulus.sf;
    cond(i).angle = p.defaultParameters.stimulus.angle;
    cond(i).range = p.defaultParameters.stimulus.range;
    if length(p.defaultParameters.stimulus.fullField) > 1
        cond(i).fullField = p.defaultParameters.stimulus.fullField(i);
    else
        cond(i).fullField = p.defaultParameters.stimulus.fullField;
    end
    c{i} = generateCondList(cond(i),side,'block',1, 5);
end
p.trial.allconditions = c;
p.trialMem.whichConditions = 0;
p.conditions=p.trial.allconditions{p.trialMem.whichConditions + 1};

p.trial.pldaps.finish = length(p.conditions);



%% display stats
p.trialMem.stats.cond={'angle','sf','range'}; %conditions to display
[A,B,C] = ndgrid(unique(horzcat(cond.angle)),unique(horzcat(cond.sf)),unique(horzcat(cond.range)));
p.trialMem.stats.val = [A(:),B(:),C(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);