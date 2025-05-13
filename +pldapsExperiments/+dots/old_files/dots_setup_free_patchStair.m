function p = dots_setup_free_patchStair(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.dots.dotstrial_free_patchStair';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
%p.trial.stimulus.duration.ITI = 3;

%% conditions:
side.par = 'direction';
side.match=p.defaultParameters.stimulus.direction;

%staircase on space bar %8/7/2023 think this is where I Need to add stair
%as the variable on the spacebar
for i = 1:length(p.defaultParameters.stimulus.stair)
     cond(i).stair=p.defaultParameters.stimulus.stair(i);%added by RV 8/7/23
     cond(i).direction=p.defaultParameters.stimulus.direction;
     cond(i).stimSide=p.defaultParameters.stimulus.stimSide;
     %cond(i).offset=p.defaultParameters.stimulus.offset; %RV removed the (i)
     c{i}=generateCondList(cond(i),side,'pseudo',250);
end


p.trial.allconditions = c;
p.trialMem.whichConditions = 0;
p.conditions=p.trial.allconditions{p.trialMem.whichConditions + 1};

p.trial.pldaps.finish = length(p.conditions);



%% display stats
%we want percent correct for left/right and the positions to check for bias
p.trialMem.stats.cond={'direction', 'stimSide'}; %conditions to display
[A,B] = ndgrid(cond(1).direction,cond(1).stimSide);
p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);

%also want the list of coherences shown
nCoh=1/p.defaultParameters.stimulus.step+1;
p.trialMem.stats.count.coh=zeros(nCoh,2);
p.trialMem.stats.count.coh(:,1)=round([0:p.defaultParameters.stimulus.step:1]*100);