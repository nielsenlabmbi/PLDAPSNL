function p=gambling_setup(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.gambling.gambling';

%% set general parameters
p.trial.stimulus.forceCorrect = p.defaultParameters.stimulus.forceCorrect;

%% set timing parameters
p.trial.stimulus.duration.ITI = 3; %ITI in s


%% conditions:

%%%%%%%%%% Conditions are fixed (same) on every trial. There is no 'correct
%%%%%%%%%% side', so we cannot use generateCondList in the ususal way
for i = 1:200;
    c{i}.gambleAmt = p.trial.stimulus.gambleAmt;
    c{i}.fixedAmt = p.trial.stimulus.fixedAmt;
    c{i}.probability = p.trial.stimulus.probability;
    c{i}.fixedPort = p.trial.stimulus.fixedPort; %fixed port will be the left port 
    c{i}.gamblePort = p.trial.stimulus.gamblePort;
end

p.conditions=c;

p.trial.pldaps.finish = length(p.conditions);

%% display stats

p.trialMem.stats.cond={'fixedAmt', 'gambleAmt'}; %conditions to display
[A,B] = ndgrid(p.trial.stimulus.fixedAmt,p.trial.stimulus.gambleAmt);
p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
% 
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);