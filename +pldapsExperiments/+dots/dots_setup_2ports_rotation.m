function p = dots_setup_2ports_rotation(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.dots.dotstrial_2ports_rotation';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.defaultParameters.stimulus.duration.ITI; %ITI in s


%% conditions:
% cond.dotCoherence = 1;
% cond.dotSpeed = p.defaultParameters.stimulus.dotSpeed;
% cond.direction = [0 180];

cond.dotCoherence = p.defaultParameters.stimulus.dotCoherence;
cond.dotSpeed = p.defaultParameters.stimulus.dotSpeed;
cond.direction = [0 180];
cond.dotLifetime = p.defaultParameters.stimulus.dotLifetime;

side.par = 'direction';
side.match=[0 180];

c=generateCondList(cond,side,'pseudo',ceil(500/(length(cond.dotCoherence)*2)));
%c1=generateCondList(cond,side,'pseudo',ceil(500/(length(cond.dotCoherence)*2)));

%p.trial.allconditions = c1;%{c,c1};
%p.trialMem.whichConditions = 0;

p.conditions = c;%p.trial.allconditions{p.trialMem.whichConditions + 1};

p.trial.pldaps.finish = length(p.conditions);


%% display stats
p.trialMem.stats.cond={'direction', 'dotCoherence'}; %conditions to display
[A,B] = ndgrid(cond.direction,cond.dotCoherence);
p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);