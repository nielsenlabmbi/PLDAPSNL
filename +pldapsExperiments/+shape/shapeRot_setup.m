function p=shapeRot_setup(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.shape.shapeRot_trial';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = 3; %ITI in s


%% conditions:
%cond.posSide=[0 1]; %positive stimulus can be either on left or right
side.par='posSide';
side.match=[0 1];


%for i = 1:length(p.defaultParameters.stimulus.shapeNeg)
for i = 1:length(p.defaultParameters.stimulus.shapePos)

    cond(i).posSide=[0 1];
    cond(i).mov=p.defaultParameters.stimulus.mov;
    cond(i).shapeNeg=p.defaultParameters.stimulus.shapeNeg;
    cond(i).shapePos=p.defaultParameters.stimulus.shapePos(i);


    c{i}=generateCondList(cond(i),side,'pseudo',500);

    p.trial.allconditions = c;
    p.trialMem.whichConditions = 0;
    p.conditions=p.trial.allconditions{p.trialMem.whichConditions + 1};
    
    p.trial.pldaps.finish = length(p.conditions);
end
%p.conditions=c;





%% display stats
%p.trialMem.stats.cond={'posSide','shapeNeg'}; %conditions to display
p.trialMem.stats.cond={'posSide','shapePos'}; %conditions to display

[A,B] = ndgrid([0 1],[1 3]);
p.trialMem.stats.val = [A(:),B(:)]';

nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);
