function p = perim_setup_free(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.perimeter.perim_trial_free';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
%p.trial.stimulus.duration.ITI = 3;

%% conditions:
side.par = 'stimSide';
side.match=p.defaultParameters.stimulus.stimSide;

%random position on spacebar
for i = 1:length(p.defaultParameters.stimulus.randPos) 
    cond(i).randPos=p.defaultParameters.stimulus.randPos(i);
    cond(i).stimSide=p.defaultParameters.stimulus.stimSide;
    cond(i).offset=p.defaultParameters.stimulus.offset;
    c{i}=generateCondList(cond(i),side,'pseudo',250);
end


p.trial.allconditions = c;
p.trialMem.whichConditions = 0;
p.conditions=p.trial.allconditions{p.trialMem.whichConditions + 1};

p.trial.pldaps.finish = length(p.conditions);



%% display stats
%we want percent correct for left/right to check for bias
p.trialMem.stats.cond={'stimSide'}; %conditions to display
%[A,B] = ndgrid(cond(1).direction,cond(1).stimSide);
%p.trialMem.stats.val = [A(:),B(:)]';
p.trialMem.stats.val = cond(1).stimSide;
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);
