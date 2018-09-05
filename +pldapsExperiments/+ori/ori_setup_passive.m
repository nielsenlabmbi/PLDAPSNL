function p=ori_setup_passive(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.ori.ori_passive_view';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.defaultParameters.stimulus.duration.ITI; %ITI in s


%% conditions:
side.par = 'rotation';
side.match=[-1 1];

for i = 1:length(p.trial.stimulus.offsets)
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



%% display stats
p.trialMem.stats.cond={'rotation','displacement'}; %conditions to display
A = []; B = []; 
for i = 1:length(p.trial.stimulus.offsets)
    [aa,bb] = ndgrid(cond(i).rotation,cond(i).displacement);
    A = [A; aa(:)]; B = [B; bb(:)];
end

p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);