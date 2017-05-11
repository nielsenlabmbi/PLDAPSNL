function p=plaid_setup2(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.plaid.plaidVersion2';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = 3; %ITI in s


%% conditions:
cond.ori=p.trial.stimulus.ori; 
cond.plaid=p.trial.stimulus.plaid;
side.par='ori';
side.match=[45 135 90];

if strcmp(p.trial.stimulus.runtype,'block')
    c=generateCondList(cond,side,'block',20,p.trial.stimulus.blocklength);
else
    c=generateCondList(cond,side,'pseudo',500);
end

p.conditions=c;

p.trial.pldaps.finish = length(p.conditions);

%% display stats
p.trialMem.stats.cond={'ori'}; %conditions to display
p.trialMem.stats.val=[45 90 135]; %values for the conditions

nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);

%% for user control over stimulus position
p.trialMem.stimulus.offset=p.trial.stimulus.iniOffset;