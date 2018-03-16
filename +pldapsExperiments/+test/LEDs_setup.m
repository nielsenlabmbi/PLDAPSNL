function p=LEDs_setup(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.test.LED_trial';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.trial.stimulus.duration.ITI;

%% conditions:
cond.LED=p.trial.stimulus.LEDCh; %3 test LEDS
cond.LEDSt = p.trial.stimulus.LEDChSt;
cond.middle = [-1 1 -1];
side.par='middle';
side.match=[-1 1 -1];

c=generateCondList(cond,side,'pseudo',200);

p.conditions=c;

p.trial.pldaps.finish = length(p.conditions);

% %% display stats
% p.trialMem.stats.cond={'color'}; %conditions to display
% p.trialMem.stats.val=[0 1]; %values for the conditions
% 
% nCond=size(p.trialMem.stats.val,2);
% p.trialMem.stats.count.correct=zeros(1,nCond);
% p.trialMem.stats.count.incorrect=zeros(1,nCond);
% p.trialMem.stats.count.Ntrial=zeros(1,nCond);