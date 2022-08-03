function p = drifting_direction_setup(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.drifting.drifting_direction_trial';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.defaultParameters.stimulus.duration.ITI; %ITI in s


%% conditions:
% cond.dotCoherence = 1;
% cond.dotSpeed = p.defaultParameters.stimulus.dotSpeed;
% cond.direction = [0 180];

side.par = 'grat_direction';
side.match=[1 0];
% for i = 1:length(p.defaultParameters.stimulus.grat_direction)
cond.dotCoherence = p.defaultParameters.stimulus.dotCoherence;
cond.dotSpeed = p.defaultParameters.stimulus.dotSpeed;
cond.grat_direction = p.defaultParameters.stimulus.grat_direction;
cond.dotLifetime = p.defaultParameters.stimulus.dotLifetime;
cond.angle = 135;
cond.t_period = p.defaultParameters.stimulus.t_period;
cond.type=p.trial.stimulus.stimtype;
c = generateCondList(cond,side,'pseudo',ceil(500/(length(cond.dotCoherence)*2)));
% end
p.trial.allconditions = c;

%p.trial.allconditions = {c,c1};
%p.trialMem.whichConditions = 0;
p.conditions=c;%p.trial.allconditions{p.trialMem.whichConditions + 1};

p.trial.pldaps.finish = length(p.conditions);


%% display stats
p.trialMem.stats.cond={'grat_direction', 'type'}; %conditions to display
[A,B] = ndgrid(cond(1).grat_direction,[1:1:length(p.trial.stimulus.t_period)]);
p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);

p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);