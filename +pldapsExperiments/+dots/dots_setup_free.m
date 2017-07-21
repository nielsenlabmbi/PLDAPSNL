function p = dots_setup_free(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.dots.dotstrial_free';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.defaultParameters.stimulus.duration.ITI; %ITI in s


%% conditions:
cond.dotCoherence = p.defaultParameters.stimulus.dotCoherence;
cond.dotSpeed = p.defaultParameters.stimulus.dotSpeed;
cond.direction = [0 90 180];
side.par = 'direction';
side.match=[0 180 90];

c=generateCondList(cond,side,'pseudo',ceil(500/(length(cond.dotCoherence)*2)));

p.conditions=c;

p.trial.pldaps.finish = length(p.conditions);

%% display stats
p.trialMem.stats.cond={'direction'}; %conditions to display
p.trialMem.stats.val=[0 90 180]; %values for the conditions
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);