function p = lesion_dots_setup_P2Test(p)
%this phase implements the tunnel/more limited viewing time

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.lesion.Trials.lesion_dots_trial_P2';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;


%% conditions - use Gellermann sequence

%iterate over trials lists accesible with space bar (each has an entry in
%Ncond)
for i=1:length(p.trial.stimulus.cond.Ncond) 
    c{i}=generateCondList_Gellerm(p.trial.stimulus.cond.Ncond(i));
end

%build complete set
p.trial.allconditions = c;
p.trialMem.whichConditions = 0; %index into trialslist; 0 is easier for mod
p.conditions=p.trial.allconditions{1}; %set to first trials list


p.trial.pldaps.finish = length(p.conditions);


%% initialize trial counter

%side counter
pds.behavior.resetSideCounter(p);

%condition counter
pds.behavior.resetCondCounter(p,p.trial.stimulus.cond.counterNames);

%percent correct for left right
%p.trialMem.stats.cond={'direction'}; %condition to display
%p.trialMem.stats.val=cond.direction; %values for the conditions

%nCond=size(p.trialMem.stats.val,2);
%p.trialMem.stats.count.correct=zeros(1,nCond);
%p.trialMem.stats.count.incorrect=zeros(1,nCond);
%p.trialMem.stats.count.Ntrial=zeros(1,nCond);
