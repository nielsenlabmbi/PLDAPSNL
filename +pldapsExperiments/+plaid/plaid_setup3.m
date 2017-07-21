function p=plaid_setup3(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.plaid.plaidVersion4';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = 3; %ITI in s


%% conditions:
cond.ori=p.trial.stimulus.ori; 
cond.plaid=p.trial.stimulus.plaid;
cond.type=p.trial.stimulus.stimtype;
cond.dotCoherence = p.trial.stimulus.dotCoherence;
cond.dotSpeed = p.trial.stimulus.dotSpeed;

cond1.ori=p.trial.stimulus.ori1; 
cond1.plaid=p.trial.stimulus.plaid1;
cond1.type=p.trial.stimulus.stimtype1;
cond1.dotCoherence = p.trial.stimulus.dotCoherence;
cond1.dotSpeed = p.trial.stimulus.dotSpeed;

side.par='ori';
side.match=[45 135 90];
c = generateCondList(cond,side,'pseudo',round(500/(length(cond.type)*length(cond.plaid)*length(cond.ori))));
c1 = generateCondList(cond1,side,'pseudo',round(500/(length(cond1.type)*length(cond1.plaid))*length(cond1.ori)));

% if strcmp(p.trial.stimulus.runtype,'block')
%     c=generateCondList(cond,side,'block',20,p.trial.stimulus.blocklength);
% else
%     c=generateCondList(cond,side,'pseudo',500);
% end
p.trial.allconditions = {c,c1};
p.trialMem.whichConditions = 0;
p.conditions=p.trial.allconditions{p.trialMem.whichConditions + 1};

p.trial.pldaps.finish = length(p.conditions);

%% display stats
% p.trialMem.stats.cond={'ori'}; %conditions to display
% p.trialMem.stats.val=[45 90 135]; %values for the conditions
% 
% nCond=size(p.trialMem.stats.val,2);

p.trialMem.stats.cond={'ori', 'type'}; %conditions to display
[A,B] = ndgrid(cond.ori,unique(cond.type));
p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);

p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);

%% for user control over stimulus position
p.trialMem.stimulus.offset=p.trial.stimulus.iniOffset;