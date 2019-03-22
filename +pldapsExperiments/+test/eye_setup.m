function p=eye_setup(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.test.eye_trial';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.defaultParameters.stimulus.duration.ITI; %ITI in s


%% conditions:
side.par = 'sidematch';
side.match=[2 1];
cond.sidematch = [1 2];
cond.color = p.defaultParameters.stimulus.color;
%cond.position = p.defaultParameters.stimulus.position;
cond.direction = p.defaultParameters.stimulus.direction;
cond.pursuit = p.defaultParameters.stimulus.pursuit;
cond.dFrame = p.defaultParameters.stimulus.dFrame;
c=generateCondList_sides(cond,side,'pseudo',ceil(500/(length(cond.direction)*2)));

p.conditions=c;

p.trial.pldaps.finish = length(p.conditions);


%% display stats
p.trialMem.stats.cond={'direction','color'}; %conditions to display
[A,B] = ndgrid(cond.direction,cond.color);
p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);

p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);