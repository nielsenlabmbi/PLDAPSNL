function p = lesion_dots_setup_P1(p)
%this phase implements basic left/right dot discrimination

%% basic definitions
p = pdsDefaultTrialStructureBL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.lesion.Trials.lesion_dots_trial_P1';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;


%% conditions:
side.par = 'direction';
side.match=p.defaultParameters.stimulus.direction;

cond.direction=p.defaultParameters.stimulus.direction; %stimulus directoin
c=generateCondList(cond,side,'pseudo',500);

p.conditions=c;

p.trial.pldaps.finish = length(p.conditions);


%% display stats
%percent correct for left right
p.trialMem.stats.cond={'direction'}; %condition to display
p.trialMem.stats.val=cond.direction; %values for the conditions

nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);
