function p=square_setup_free(p)
%experiment setup file for a simple test experiment

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.stereo.squaretrial_free_dots';

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = p.defaultParameters.stimulus.duration.ITI; %ITI in s


%% conditions:
cond.angle=[0 1]; %positive stimulus can be either on left or right
side.par='angle';
side.match=[0 1];

%side.par = 'angle';
%side.match = [1 0];
%cond.angle = [1 0];%p.defaultParameters.stimulus.angle;
c=generateCondList(cond,side,'pseudo',500);

p.conditions=c;

p.trial.pldaps.finish = length(p.conditions);



%% display stats
p.trialMem.stats.cond={'angle'}; %conditions to display
p.trialMem.stats.val=cond.angle; %values for the conditions

nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);