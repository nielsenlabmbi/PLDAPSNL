function p=oridiscrim(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.test.oritrial';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = 3; %ITI in s


%% conditions:
cond.displacement = [10 20 30 40]; %use squares of 2 colors
cond.phase = [0 180];
cond.rotation = [-1 1];
cond.sf = [0.25];
cond.angle = [45];
cond.range = [121];
side.par = 'rotation';
side.match=[-1 1];

c=generateCondList(cond,side,'pseudo',ceil(500/(length(cond.displacement)*2)));

p.conditions=c;

p.trial.pldaps.finish = length(p.conditions);

%% display stats
p.trialMem.stats.cond={'displacement', 'rotation'}; %conditions to display
[A,B] = ndgrid(cond.displacement,cond.rotation);
p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);