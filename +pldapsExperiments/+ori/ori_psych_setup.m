function p=ori_psych_setup(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.ori.ori_psych_trial';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.defaultParameters.stimulus.duration.ITI; %ITI in s


%% new conditions for levels:

side.par = 'angle';
side.match=p.defaultParameters.stimulus.sideMatch;

if iscell(p.defaultParameters.stimulus.angle)
    for i = 1:length(p.defaultParameters.stimulus.angle)
        cond(i).angle = p.defaultParameters.stimulus.angle{i};
        cond(i).sf = p.defaultParameters.stimulus.sf;
        cond(i).range = p.defaultParameters.stimulus.range;
        cond(i).direction = p.defaultParameters.stimulus.direction;
        if length(p.defaultParameters.stimulus.fullField) > 1
            cond(i).fullField = p.defaultParameters.stimulus.fullField(:);
        else
            cond(i).fullField = p.defaultParameters.stimulus.fullField;
        end
        c{i}=generateCondList_sides(cond(i),side,'pseudo',500);
    end
    p.trial.allconditions = c;
    p.trialMem.whichConditions = 0;
    p.conditions=p.trial.allconditions{p.trialMem.whichConditions + 1};
    
    p.trial.pldaps.finish = length(p.conditions);
    
else
    cond.angle = p.defaultParameters.stimulus.angle;
    cond.sf = p.defaultParameters.stimulus.sf;
    cond.range = p.defaultParameters.stimulus.range;
    cond.direction = p.defaultParameters.stimulus.direction;
    if length(p.defaultParameters.stimulus.fullField) > 1
            cond(i).fullField = p.defaultParameters.stimulus.fullField(i);
    else
            cond(i).fullField = p.defaultParameters.stimulus.fullField;
    end
    
    if length(cond.angle) > 2
       c=generateCondList_sides(cond,side,'pseudo',ceil(500/(length(cond.angle)*2)));
    else
        c=generateCondList(cond,side,'pseudo',ceil(500/(length(cond.angle)*2)));
    end
    %there might be a big flag here
    p.conditions=c;
    p.trial.pldaps.finish = length(p.conditions);
end

    


%% display stats
p.trialMem.stats.cond={'angle','direction','sf','range'}; %conditions to display
[A,B,C,D] = ndgrid(unique(horzcat(cond.angle)),unique(horzcat(cond.direction)),unique(horzcat(cond.sf)),unique(horzcat(cond.range)));
p.trialMem.stats.val = [A(:),B(:),C(:), D(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);