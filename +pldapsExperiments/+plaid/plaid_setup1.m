function p=plaid_setup1(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.plaid.plaidVersion1';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = 3; %ITI in s


%% conditions:
cond.ori=90; 
cond.plaid=0;
side.par='ori';
side.match=[-1 -1 90];

c=generateCondList(cond,side,'pseudo',500);

p.conditions=c;

p.trial.pldaps.finish = length(p.conditions);

%% display stats
p.trialMem.stats.cond={'ori'}; %conditions to display
p.trialMem.stats.val=90; %values for the conditions

nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);