function p=plain2(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that get's call for each frame state
p.trial.pldaps.trialFunction='test.basicTest';

%% timing
%five seconds per trial.
p.trial.pldaps.maxTrialLength = 5;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

%% stimulus colors
p.trial.stimulus.stimColor1=[1 0 0];
p.trial.stimulus.stimColor2=[0 1 0];

%% conditions:
cond.color=[0 1]; %use squares of 2 colors
nrCond=2;

c=cell(1,nrCond);
for i=1:nrCond
    c{i}.color=cond.color(i);
end

nrTrialsPerCond=10;
cc=repmat(c,1,nrTrialsPerCond);

p.conditions=cc;

p.trial.pldaps.finish = length(p.conditions);