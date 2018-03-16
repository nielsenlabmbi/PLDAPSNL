function p=gambling0_setup(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.gambling.gambling0';

%% set general parameters
p.trial.stimulus.forceCorrect = p.defaultParameters.stimulus.forceCorrect;

%% set timing parameters
p.trial.stimulus.duration.ITI = 3; %ITI in s


%% conditions:
cond.offset=[-1 1]; %use squares of 2 colors
cond.intensity = p.trial.stimulus.intensity;
cond.reference = p.trial.stimulus.reference;
side.par='offset';
side.match=[-1 1];


c=generateCondList_sides_gambling(cond,side,p.trial.stimulus.runtype,50);

p.conditions=c;

p.trial.pldaps.finish = length(p.conditions);

%% display stats

p.trialMem.stats.cond={'intensity', 'reference'}; %conditions to display
[A,B] = ndgrid(cond.intensity,unique(cond.reference));
p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
% 
% p.trialMem.stats.cond={'intensity'}; %conditions to display
% p.trialMem.stats.val = cond.intensity;
% nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);