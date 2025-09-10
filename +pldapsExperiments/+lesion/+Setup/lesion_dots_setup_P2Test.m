function p = lesion_dots_setup_P2Test(p)
%this phase implements the tunnel/more limited viewing time

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.lesion.Trials.lesion_dots_trial_P2';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;


%% conditions - use Gellermann sequence

c=generateCondList_Gellerm(p.trial.stimulus.Ncond);

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
