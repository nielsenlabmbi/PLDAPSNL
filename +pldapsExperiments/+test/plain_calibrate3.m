function p=plain_calibrate3(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.test.calibrate_3spouts';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = 2; %ITI in s


%% conditions:
cond.color=[0 1]; %use squares of 2 colors
side.par='color';
side.match=[0 1];

c=generateCondList(cond,side,'pseudo',30);

p.conditions=c;

p.trial.pldaps.finish = length(p.conditions);

%% display stats
p.trialMem.stats.cond={'color'}; %conditions to display
p.trialMem.stats.val=[0 1]; %values for the conditions

nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);