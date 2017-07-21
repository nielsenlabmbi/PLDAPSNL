function p=ori_setup(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.ori.oritrial';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.defaultParameters.stimulus.duration.ITI; %ITI in s


%% conditions:
cond.displacement = p.defaultParameters.stimulus.offsets; %use squares of 2 colors
cond.phase = [0 180];
cond.rotation = [-1 1];
cond.sf = p.defaultParameters.stimulus.sf;
cond.angle = p.defaultParameters.stimulus.angle;
cond.range = p.defaultParameters.stimulus.range;
side.par = 'rotation';
side.match=[-1 1];

if strcmp(p.defaultParameters.stimulus.runtype,'block')
    c=generateCondList(cond,side,'block',ceil(400/(p.defaultParameters.stimulus.blockLength)), p.defaultParameters.stimulus.blockLength);
else
    c=generateCondList(cond,side,'pseudo',ceil(400/(length(cond.displacement)*2)));
end

p.conditions=c;

p.trial.pldaps.finish = length(p.conditions);

%% display stats
p.trialMem.stats.cond={'displacement', 'rotation'}; %conditions to display
[A,B] = ndgrid(cond.displacement,cond.rotation);
p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);