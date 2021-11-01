function p=som_setuphp(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.som.somtrialhp';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.defaultParameters.stimulus.duration.ITI; %ITI in s


%% conditions:
side.par = 'curvetype';
if isfield(p.defaultParameters,'sideMatch')
    side.match=p.defaultParameters.sideMatch;
else
    side.match=[1 2];
end

cond(1).curevetype=p.defaultParameters.stimulus.curvetype;
cond(1).shapeid=p.defaultParameters.stimulus.shapeid;

c{1}=generateCondList_sides(cond(1),side,'pseudo',ceil(500/(length(cond(1).curvetype)*2)));


p.trial.allconditions = c;
p.trialMem.whichConditions = 0;
p.conditions=p.trial.allconditions{p.trialMem.whichConditions + 1};

p.trial.pldaps.finish = length(p.conditions);



%% display stats
p.trialMem.stats.cond={'curvetype','shapeid'}; %conditions to display
A = []; B = []; 
for i = 1:length(p.trial.stimulus.offsets)
    [aa,bb] = ndgrid(cond(i).curvetype,cond(i).shapeid);
    A = [A; aa(:)]; B = [B; bb(:)];
end

p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);