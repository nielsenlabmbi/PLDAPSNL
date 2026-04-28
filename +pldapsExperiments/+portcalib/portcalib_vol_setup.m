function p=portcalib_vol_setup(p)
%box acclimatization code

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.portcalib.portcalib_vol_trial';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = 0.1; %ITI in s


%% conditions:
%this is just a placeholder
c=generateCondList_Gellerm(2);

p.conditions=c;

p.trial.pldaps.finish = length(p.conditions);

