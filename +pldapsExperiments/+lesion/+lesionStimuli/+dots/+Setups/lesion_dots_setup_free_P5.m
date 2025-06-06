function p = lesion_dots_setup_free_P5(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.lesion.lesionStimuli.dots.Trials.lesion_dots_trial_free_P5';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
%p.trial.stimulus.duration.ITI = 3;

%% conditions:
side.par = 'direction';
side.match=p.defaultParameters.stimulus.direction;

%staircase on space bar
for i = 1:length(p.defaultParameters.stimulus.stair)
     cond(i).stair=p.defaultParameters.stimulus.stair(i);
     cond(i).direction=p.defaultParameters.stimulus.direction;
     %cond(i).width=p.defaultParameters.stimulus.width;
     %cond(i).durStim = p.defaultParameters.stimulus.durStim;
     cond(i).stimSide=p.defaultParameters.stimulus.stimSide;
     c{i}=generateCondList(cond(i),side,'pseudo',250);
end


p.trial.allconditions = c;
p.trialMem.whichConditions = 0;
p.conditions=p.trial.allconditions{p.trialMem.whichConditions + 1};

p.trial.pldaps.finish = length(p.conditions);



%% display stats
%we want percent correct for left/right and the positions to check for bias

%p.trialMem.stats.cond={'direction', 'width'}; %conditions to display
%[A,B] = ndgrid(cond(1).direction,cond(1).width);

p.trialMem.stats.cond={'direction', 'stimSide'}; %conditions to display
%if length(cond)>1
    [A,B] = ndgrid(cond(1).direction,[cond(:).stimSide]);
%else
    %[A,B] = ndgrid(cond(1).direction,cond(1).durStim);

%end

p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);

%also want the list of coherences shown
nCoh=1/p.defaultParameters.stimulus.step+1;
p.trialMem.stats.count.coh=zeros(nCoh,2);
p.trialMem.stats.count.coh(:,1)=[0:p.defaultParameters.stimulus.step:1];