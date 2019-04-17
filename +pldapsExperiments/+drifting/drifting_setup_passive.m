function p=drifting_setup_passive(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.drifting.drifting_passive_view';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.defaultParameters.stimulus.duration.ITI; %ITI in s


%% conditions:
% cond.dotCoherence = 1;
% cond.dotSpeed = p.defaultParameters.stimulus.dotSpeed;
% cond.direction = [0 180];
side.par = 'rotation';
side.match=[-1 1];

for i = 1:length(p.trial.stimulus.offsets)
    
cond(i).t_period = p.defaultParameters.stimulus.t_period(i);
cond(i).direction = p.defaultParameters.stimulus.direction{i};
cond(i).displacement = p.defaultParameters.stimulus.offsets{i};
%cond(i).phase = [0 180];
cond(i).rotation = [-1 1];
cond(i).sf = p.defaultParameters.stimulus.sf;
cond(i).angle = p.defaultParameters.stimulus.angle;
cond(i).range = p.defaultParameters.stimulus.range;
cond(i).fullField = p.defaultParameters.stimulus.fullField(i); 
c{i}=generateCondList_sides(cond(i),side,'pseudo',ceil(500/(length(cond(i).displacement)*2)));
end

p.trial.allconditions = c;
p.trialMem.whichConditions = 0;
p.conditions=p.trial.allconditions{p.trialMem.whichConditions + 1};

p.trial.pldaps.finish = length(p.conditions);

p.trial.allconditions = c;

%p.trial.allconditions = {c,c1};
p.trialMem.whichConditions = 0;
p.conditions=p.trial.allconditions{p.trialMem.whichConditions + 1};

p.trial.pldaps.finish = length(p.conditions);


%% display stats
p.trialMem.stats.cond={'direction', 'type'}; %conditions to display
[A,B] = ndgrid(cond(1).direction,[1:1:length(p.trial.stimulus.t_period)]);
p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);

p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);