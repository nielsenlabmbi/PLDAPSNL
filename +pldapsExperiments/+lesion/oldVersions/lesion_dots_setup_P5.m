function p = lesion_dots_setup_P5(p)
%This phase adjusts the stimulus offset

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.lesion.Trials.lesion_dots_trial_P5';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;


%% conditions:
side.par = 'direction';
side.match=p.defaultParameters.stimulus.direction;

cond.direction=p.defaultParameters.stimulus.direction; %stimulus direction
cond.stimSide=p.defaultParameters.stimulus.stimSide; %stimulus side
c=generateCondList(cond,side,'pseudo',500);

p.conditions=c;

p.trial.pldaps.finish = length(p.conditions);


%% display stats
%we want percent correct for left/right and the positions to check for bias
p.trialMem.stats.cond={'direction', 'stimSide'}; %conditions to display
[A,B] = ndgrid(cond.direction,[cond.stimSide]);

p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);

p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);
