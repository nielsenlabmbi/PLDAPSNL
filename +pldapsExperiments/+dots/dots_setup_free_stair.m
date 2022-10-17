function p = dots_setup_free_stair(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.dots.dotstrial_free_stair';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = 3;

%% conditions:
side.par = 'direction';
side.match=p.defaultParameters.stimulus.direction;


for i = 1:length(p.defaultParameters.stimulus.stair)
    cond(i).dotCoherence = p.defaultParameters.stimulus.dotCoherence;
    cond(i).dotSpeed = p.defaultParameters.stimulus.dotSpeed;
    cond(i).direction = p.defaultParameters.stimulus.direction;
    cond(i).dotLifetime = p.defaultParameters.stimulus.dotLifetime;
    cond(i).stair=p.defaultParameters.stimulus.stair(i);
        
    c{i}=generateCondList(cond,side,'pseudo',ceil(500/(length(cond.dotCoherence)*2)));
end

p.trial.allconditions = c;
p.trialMem.whichConditions = 0;
p.conditions=p.trial.allconditions{p.trialMem.whichConditions + 1};

p.trial.pldaps.finish = length(p.conditions);



%% display stats
p.trialMem.stats.cond={'direction', 'stair'}; %conditions to display
[A,B] = ndgrid(cond.direction,cond.stair);
p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);