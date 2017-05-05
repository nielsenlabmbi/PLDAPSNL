function p = opticFlow_setup(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.test.opticFlowTrial';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.defaultParameters.stimulus.duration.ITI; %ITI in s


%% conditions:
cond.deltaX = p.defaultParameters.stimulus.deltaX;
cond.deltaY = p.defaultParameters.stimulus.deltaY;
cond.stimDir = [-1];
side.par = 'stimDir';
side.match=[0 180];

c=generateCondList(cond,side,'pseudo',ceil(500/(length(cond.deltaX)*2)));

p.conditions=c;

p.trial.pldaps.finish = length(p.conditions);

%% display stats
p.trialMem.stats.cond={'stimDir'}; %conditions to display
[A,B] = ndgrid(cond.stimDir);
p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);