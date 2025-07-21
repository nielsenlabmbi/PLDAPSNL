function p=lesion_dots_setup_P0(p)
%box acclimatization code

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.lesion.Trials.lesion_dots_trial_P0';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = 1; %ITI in s


%% conditions:
cond.color=[0 1]; %use squares of 2 colors
side.par='color';
side.match=[0 1];

c=generateCondList(cond,side,'pseudo',200);

p.conditions=c;

p.trial.pldaps.finish = length(p.conditions);

