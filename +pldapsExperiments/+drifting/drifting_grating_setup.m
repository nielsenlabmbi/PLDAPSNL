function p = drifting_grating_setup(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.drifting.drifting_grating_trial';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.defaultParameters.stimulus.duration.ITI; %ITI in s


%% conditions:
% cond.dotCoherence = 1;
% cond.dotSpeed = p.defaultParameters.stimulus.dotSpeed;
% cond.direction = [0 180];

side.par = 'direction';
side.match=[180 0];
% for i = 1:length(p.defaultParameters.stimulus.grat_direction)
for i = 1:length(p.defaultParameters.stimulus.fullfield)
    cond(i).direction = p.defaultParameters.stimulus.direction;
    cond(i).t_period = p.defaultParameters.stimulus.t_period;
    cond(i).fullfield = p.defaultParameters.stimulus.fullfield(i);
    c{i} = generateCondList(cond(i),side,'pseudo',ceil(500/(length(cond(i))*2)));
end
p.trial.allconditions = c;

p.trial.allconditions = c;
p.trialMem.whichConditions = 0;
p.conditions=p.trial.allconditions{p.trialMem.whichConditions + 1};

p.trial.pldaps.finish = length(p.conditions);


%% display stats
p.trialMem.stats.cond={'direction'}; %conditions to display
[A,B] = ndgrid(cond(1).direction,[1:1:length(p.trial.stimulus.t_period)]);
p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);

p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);