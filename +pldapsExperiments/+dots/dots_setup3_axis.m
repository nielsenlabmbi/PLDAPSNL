function p = dots_setup3_axis(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.dots.dotstrial_3ports_axis';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.defaultParameters.stimulus.duration.ITI; %ITI in s


%% conditions:


side.par = 'rotation';
side.match=[-1 1];
for i = 1:length(p.defaultParameters.stimulus.reference)
cond(i).dotCoherence = p.defaultParameters.stimulus.dotCoherence;
cond(i).dotSpeed = p.defaultParameters.stimulus.dotSpeed;
cond(i).dotLifetime = p.defaultParameters.stimulus.dotLifetime;
cond(i).offset = p.defaultParameters.stimulus.offset;
cond(i).rotation = [-1 1];
cond(i).reference = p.defaultParameters.stimulus.reference{i};
if isfield(p.trial.stimulus,'fracInstructTrue')
cond(i).fracInstructTrue = p.trial.stimulus.fracInstructTrue(i);
end
if length(cond(i).offset) > 2
   c{i}=generateCondList_sides(cond(i),side,'pseudo',ceil(500/(length(cond(i).offset)*2)));
else
   c{i}=generateCondList(cond(i),side,'pseudo',ceil(500/(length(cond(i).offset)*2)));
end
end

p.trial.allconditions = c;
p.trialMem.whichConditions = 0;
p.conditions=p.trial.allconditions{p.trialMem.whichConditions + 1};

p.trial.pldaps.finish = length(p.conditions);

%% display stats
p.trialMem.stats.cond={'offset', 'rotation'}; %conditions to display
[A,B] = ndgrid(cond(end).offset,cond(end).rotation);
p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);