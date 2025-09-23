function p=acuity_setup_free_P4_Stair(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.acuity.acuity_trial_free_P4_Stair';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.defaultParameters.stimulus.duration.ITI; %ITI in s


%% conditions:
side.par = 'angle';
side.match = [90 0];
for i = 1:length(p.defaultParameters.stimulus.range)
    cond(i).angle = p.defaultParameters.stimulus.angle;
    cond(i).range = p.defaultParameters.stimulus.range;
    if length(p.defaultParameters.stimulus.range) > 1
        cond(i).range = p.defaultParameters.stimulus.range{i};
    else
        cond(i).range = p.defaultParameters.stimulus.range;
    end
    c{i}=generateCondList_sides(cond(i),side,'pseudo',500);
end
p.trial.allconditions = c;
p.trialMem.whichConditions = 0;
p.conditions=p.trial.allconditions{p.trialMem.whichConditions + 1};

p.trial.pldaps.finish = length(p.conditions);



%% display stats
p.trialMem.stats.cond={'angle','range'}; %conditions to display
[A,B] = ndgrid(unique(horzcat(cond.angle)),unique(horzcat(cond.range)));
p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);
p.trialMem.stats.count.Nleft=0;
p.trialMem.stats.count.Nright=0;
p.trialMem.stats.count.NleftCorr=0;
p.trialMem.stats.count.NrightCorr=0;