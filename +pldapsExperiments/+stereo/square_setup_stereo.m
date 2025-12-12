function p=square_setup_stereo(p)

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.stereo.squaretrial_dots_stereo';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.defaultParameters.stimulus.duration.ITI; %ITI in s


%% conditions:
c{1}=generateCondList_Gellerm(p.trial.stimulus.cond.Ncond);


p.trial.allconditions = c;
p.trialMem.whichConditions = 0; %index into trialslist; 0 is easier for mod
p.conditions=p.trial.allconditions{1}; %set to first trials list

p.trial.pldaps.finish = length(p.conditions);


%% display stats
%side counter
pds.behavior.resetSideCounter(p);

%condition counter
pds.behavior.resetCondCounter(p,p.trial.stimulus.cond.counterNames);