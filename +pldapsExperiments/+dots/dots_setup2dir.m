function p = dots_setup2dir(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.dots.dotstrial2dir';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.defaultParameters.stimulus.duration.ITI; %ITI in s


%% conditions:
cond.dotCoherence = p.defaultParameters.stimulus.dotCoherence;
cond.dotSpeed = p.defaultParameters.stimulus.dotSpeed;
cond.direction = p.defaultParameters.stimulus.direction;%[0 180];
cond.dotLifetime = p.defaultParameters.stimulus.dotLifetime;
cond.addition = p.defaultParameters.stimulus.addition;
side.par = 'direction';
side.match=p.defaultParameters.stimulus.direction;
if length(cond.dotCoherence) > 2
   c=generateCondList_sides(cond,side,'pseudo',ceil(500/(length(cond.dotCoherence)*2)));
else
   c=generateCondList(cond,side,'pseudo',ceil(500/(length(cond.dotCoherence)*2)));
end
 
p.conditions=c;

p.trial.pldaps.finish = length(p.conditions);

%% display stats
p.trialMem.stats.cond={'direction', 'dotCoherence'}; %conditions to display
[A,B] = ndgrid(cond.direction,cond.dotCoherence);
p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);