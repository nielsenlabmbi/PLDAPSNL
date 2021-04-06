function p = oflow_setup_free(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.opticflow.oflowtrial_free';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = 3;

%% conditions:
side.par = 'direction';
side.match=p.defaultParameters.stimulus.direction;

if iscell(p.defaultParameters.stimulus.dotCoherence)
    for i = 1:length(p.defaultParameters.stimulus.dotCoherence)
        cond(i).dotCoherence = p.defaultParameters.stimulus.dotCoherence{i};
        cond(i).direction = p.defaultParameters.stimulus.direction;
        
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
    cond.dotCoherence = p.defaultParameters.stimulus.dotCoherence;
    cond.direction = p.defaultParameters.stimulus.direction;%[0 180];
    if length(cond.dotCoherence) > 2
        c=generateCondList_sides(cond,side,'pseudo',ceil(500/(length(cond.dotCoherence)*2)));
    else
        c=generateCondList(cond,side,'pseudo',ceil(500/(length(cond.dotCoherence)*2)));
    end
    
    p.conditions=c;
    
    p.trial.pldaps.finish = length(p.conditions);
end


%% display stats
p.trialMem.stats.cond={'direction', 'dotCoherence'}; %conditions to display
if length(cond)>1
    [A,B] = ndgrid(cond(end).direction,cond(end).dotCoherence);
else
[A,B] = ndgrid(cond.direction,cond.dotCoherence);
end
p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);