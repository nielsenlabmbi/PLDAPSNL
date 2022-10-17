function p=ori_thres_setup(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.ori.ori_thres_trial';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.defaultParameters.stimulus.duration.ITI; %ITI in s


%% conditions:
side.par = 'sidePar';
side.match = [1 0];

for i = 1:length(p.trial.stimulus.angle)
    cond(i).sf = p.defaultParameters.stimulus.sf;
    cond(i).angle = p.defaultParameters.stimulus.angle{i};
    cond(i).range = p.defaultParameters.stimulus.range;
    cond(i).fullField = p.defaultParameters.stimulus.fullField;
    cond(i).sidePar = p.defaultParameters.stimulus.sidePar;
    c{i}=generateCondList(cond(i),side,'pseudo',ceil(500/(length(cond(i))*2)));
end


p.trial.allconditions = c;
p.trialMem.whichConditions = 0;
p.conditions=p.trial.allconditions{p.trialMem.whichConditions + 1};

p.trial.pldaps.finish = length(p.conditions);



%% display stats
p.trialMem.stats.cond={'sidePar','angle'}; %conditions to display
A = []; B = []; 
for i = 1:length(p.trial.stimulus.angle)
    [aa,bb] = ndgrid(cond(i).sidePar,cond(i).angle);
    A = [A; aa(:)]; B = [B; bb(:)];
end

p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);