function p=shape_setup(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.shape.shape_trial';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = 3; %ITI in s


%% conditions:
cond.posSide=[0 1]; %positive stimulus can be either on left or right
side.par='posSide';
side.match=[0 1];

c=generateCondList(cond,side,'pseudo',500);

p.conditions=c;

p.trial.pldaps.finish = length(p.conditions);



%% display stats
p.trialMem.stats.cond={'posSide'}; %conditions to display
p.trialMem.stats.val=[0 1]; %values for the conditions

nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);
