function p = lesion_dots_setup_free_P6(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.lesion.lesionStimuli.dots.Trials.lesion_dots_trial_free_P6';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
%p.trial.stimulus.duration.ITI = 3;

%% conditions:
side.par = 'direction';
side.match=p.defaultParameters.stimulus.direction;

%staircase on space bar (later)
%coherence on space bar
if iscell(p.defaultParameters.stimulus.dotCoherence)
    for i = 1:length(p.defaultParameters.stimulus.stair)
         cond(i).stair=p.defaultParameters.stimulus.stair(i);
         cond(i).direction=p.defaultParameters.stimulus.direction;
         cond(i).dotCoherence = p.defaultParameters.stimulus.dotCoherence{i}
         %cond(i).width=p.defaultParameters.stimulus.width;
         %cond(i).durStim = p.defaultParameters.stimulus.durStim;
         cond(i).stimSide=p.defaultParameters.stimulus.stimSide;
         c{i}=generateCondList(cond(i),side,'pseudo',250);
    
         if length(cond(i).dotCoherence) > 2
            c{i}=generateCondList_sides(cond(i),side,'pseudo',ceil(500/(length(cond(i).dotCoherence)*2)));
        else
            c{i}=generateCondList(cond(i),side,'pseudo',ceil(500/(length(cond(i).dotCoherence)*2)));
        end
    end
    p.trial.allconditions = c;
    p.trialMem.whichConditions = 0;
    p.conditions=p.trial.allconditions{p.trialMem.whichConditions + 1};
    
    p.trial.pldaps.finish = length(p.conditions);
else
    cond.stimSide=p.defaultParameters.stimulus.stimSide;
    cond.stair=p.defaultParameters.stimulus.stair;
    cond.dotCoherence = p.defaultParameters.stimulus.dotCoherence;
    cond.direction = p.defaultParameters.stimulus.direction;%[0 180];
    cond.dotLifetime = p.defaultParameters.stimulus.dotLifetime;
    if length(nrDots) > 2
        c=generateCondList_sides(cond,side,'pseudo',ceil(500/(length(cond.nrDots)*2)));
    else
        c=generateCondList(cond,side,'pseudo',ceil(500/(length(cond.nrDots)*2)));
    end
    
    p.conditions=c;
    
    p.trial.pldaps.finish = length(p.conditions);
end



%% display stats
%we want percent correct for left/right and the positions to check for bias

%p.trialMem.stats.cond={'direction', 'width'}; %conditions to display
%[A,B] = ndgrid(cond(1).direction,cond(1).width);

p.trialMem.stats.cond={'direction', 'stimSide', 'dotCoherence'}; %conditions to display
if length(cond)>1
    [A,B, C] = ndgrid(cond(1).direction,[cond(:).stimSide], [cond(1).dotCoherence]);
else
    [A,B, C] = ndgrid(cond.direction,[cond(:).stimSide], [cond.dotCoherence]);

end

p.trialMem.stats.val = [A(:),B(:),C(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);

%also want the list of coherences shown
nCoh=1/p.defaultParameters.stimulus.step+1;
p.trialMem.stats.count.coh=zeros(nCoh,2);
p.trialMem.stats.count.coh(:,1)=[0:p.defaultParameters.stimulus.step:1];