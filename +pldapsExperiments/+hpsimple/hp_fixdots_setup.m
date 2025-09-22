function p = hp_fixdots_setup(p)
%headfixed setup, presentation of drifting dots

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.hpsimple.hp_fixdots_trial';

%% set general parameters

%% conditions 
%we will use the usual Gellerman code here simply to run the randomization
%and generate a correctly formatted conditions structure; the side
%assignments are ignored in the trials function

%iterate over trials lists accesible with space bar (each has an entry in
%Ncond)
c{1}=generateCondList_Gellerm(p.trial.stimulus.cond.Ncond);

%build complete set
p.trial.allconditions = c;
p.trialMem.whichConditions = 0; %index into trialslist; 0 is easier for mod
p.conditions=p.trial.allconditions{1}; %set to first trials list


p.trial.pldaps.finish = length(p.conditions);

%% initialize trial counters
%side counter
pds.behavior.resetSideCounter(p);

%condition counter - meaningless here
%pds.behavior.resetCondCounter(p,p.trial.stimulus.cond.counterNames,1);
