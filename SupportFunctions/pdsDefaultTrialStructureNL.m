function p = pdsDefaultTrialStructureNL(p)
% p = pdsDefaultTrialStructureNL(p)
% defines some standard names

p.defaultParameters.good = 1;

%-------------------------------------------------------------------------%
% Colors (necessary for cluts)
p = defaultColors(p);

%-------------------------------------------------------------------------%
% Bits (necessary for event defs)
p = defaultBitNames(p);

%-------------------------------------------------------------------------%
% Stimulus side association
p.defaultParameters.stimulus.side.LEFT = 2;
p.defaultParameters.stimulus.side.RIGHT = 1;
p.defaultParameters.stimulus.side.MIDDLE = 3;


%-------------------------------------------------------------------------%
% IR beam assignments (relative to port.status)
p.defaultParameters.stimulus.port.START = 3;
p.defaultParameters.stimulus.port.LEFT = 2;
p.defaultParameters.stimulus.port.RIGHT = 1;
p.defaultParameters.stimulus.port.MIDDLE = 4;



%-------------------------------------------------------------------------%
% Indices into reward amounts (relative to behavior.reward.amount)
p.defaultParameters.stimulus.rewardIdx.START = 1;
p.defaultParameters.stimulus.rewardIdx.LEFT = 2;
p.defaultParameters.stimulus.rewardIdx.RIGHT = 3;
p.defaultParameters.stimulus.rewardIdx.MIDDLE = 4;


%-------------------------------------------------------------------------%
% States
p.defaultParameters.stimulus.states.START = 1;
p.defaultParameters.stimulus.states.STIMON = 2;
p.defaultParameters.stimulus.states.CORRECT = 3;
p.defaultParameters.stimulus.states.INCORRECT = 4;
p.defaultParameters.stimulus.states.FINALRESP = 5;
p.defaultParameters.stimulus.states.TRIALCOMPLETE = 6;
p.defaultParameters.stimulus.states.LICKDELAY = 7;