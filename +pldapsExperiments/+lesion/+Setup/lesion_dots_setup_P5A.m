function p = lesion_dots_setup_P5A(p)
%This phase adjusts the stimulus offset

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.lesion.Trials.lesion_dots_trial_P5A';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;


%% conditions - use Gellermann sequence

%iterate over trials lists accesible with space bar (each has an entry in
%Ncond)
c=generateCondList_Gellerm(p.trial.stimulus.cond.Ncond);


%build complete set
p.trial.allconditions = c;
p.trialMem.whichConditions = 0; %index into trialslist; 0 is easier for mod
p.conditions=p.trial.allconditions; %set to first trials list


p.trial.pldaps.finish = length(p.conditions);

%% initialize trial counters
%side counter
pds.behavior.resetSideCounter(p);

%condition counter
pds.behavior.resetCondCounter(p,p.trial.stimulus.cond.counterNames,1);
