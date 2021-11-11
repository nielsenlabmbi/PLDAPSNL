function p = som_setupfree(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.som.somtrial_free';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = 3;

%% conditions:

side.par = 'curvetype';
if isfield(p.defaultParameters,'sideMatch')
    side.match=p.defaultParameters.sideMatch;
else
    side.match=[1 2];
end

cond.curvetype=p.defaultParameters.stimulus.curvetype;
cond.shapeid=p.defaultParameters.stimulus.shapeid;

c=generateCondList_sides(cond,side,'pseudo',ceil(500/(length(cond.curvetype)*2)));
p.conditions=c;
    
p.trial.pldaps.finish = length(p.conditions);
 


%% display stats
p.trialMem.stats.cond={'curvetype','shapeid'}; %conditions to display

[A,B] = ndgrid(cond.curvetype,cond.shapeid);

p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);