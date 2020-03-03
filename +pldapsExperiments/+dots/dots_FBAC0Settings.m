function s = dots_FBAC0Settings
% % add eye tracking
% s.datapixx.useAsEyepos = 1;
%  s.	pldaps.	draw.	eyepos.	use = 1;
%  s.	pldaps.	draw.	eyepos.	show = 1;

%set reward amounts
s. behavior.   reward. amount = [0.02 0.06 0.06];
s.behavior.reward.pulseFreq = 3;
s.behavior.reward.pulseInt = 0.2;
s.behavior.reward.amountDelta = 0.01;
%% THIS SECTION HAS CHANGED
s.stimulus.reference = [{150} {135} {90}];
s.stimulus.reference_rotation = -1; %1 (clockwise) or -1 (counterclockwise) - switch daily
s.stimulus.offset = 90;
s.stimulus.constant = 70; %1 for coherenceq, 70 for axis, 20 for direction (easy), 3 for direction (hard), 
s.stimulus.nEasyTrials = 20;
s.stimulus.targetThreshold = 0.85; %.75 for coherence/direction, 0.85 for axis
%%
%set background color, wait color, and dot color 
s.display.bgColor = [0 0 0]; % to change to gray, comment out this line
s.stimulus.waitColor = [0 0 0]; % to change to gray, comment out this line
s.stimulus.fractionBlack = 0; % to change to black and white dots, set to 0.5
%set dot density
s.stimulus.nrDots = 250; %density of approximately 0.05. To change to 0.12, set to 250. 
%set orientation and offsets
s.stimulus.dotSize = 1.5;
s.stimulus.direction = [0 180];
s.stimulus.dotCoherence = [{1},{[[1 1 0.8 0.6 0.4 0.2]]}]; %[1 1 0.8 0.6 0.4 0.2];
s.stimulus.dotSpeed = 0.6;
s.stimulus.dotLifetime = 3;
s.stimulus.durStim = 60;
s.stimulus.frameRate = 120;
s.stimulus.nStaticFrames = 120;

%set viewing parameters

%set viewing parameterses
s.stimulus.baseline = 0.1;
s.stimulus.lickdelay = 1.7;
s.stimulus.forceCorrect_delay = 0.75;
s.stimulus.duration.ITI = 2;
s.stimulus.stimON = 0.75 + s.stimulus.nStaticFrames/s.stimulus.frameRate; %1.5 + s.stimulus.nStaticFrames/s.stimulus.frameRate
s.stimulus.waitTime = 0;
s.stimulus.trialdur = 300;
s.stimulus.timeout = 1;

%set instructive trials
s.stimulus.fracInstruct = 0.5;

%set up the viewing distances
s.display.viewdist = 45; 

% %configure ports
 s.ports.use = true;
 s.ports.nports = 3;
 s.ports.movable = true;
 s.datapixx.adc.channels = [1 3 5]; %[1 3 5 10 11];
 %s.datapixx.useAsEyepos = 0;
 %use din?
 s.datapixx.din.useFor.ports = 1;
 %turn mouse input off
s.mouse.useAsPort = 0;
s.mouse.use = 0;

% 2P room settings
%  s.datapixx.dio.useForReward = 1; 
%  s.datapixx.adc.useForReward = 0;
%  s. behavior.   reward. channel. START = 7; %dio channel for reward delivery
%  s. behavior.   reward. channel. LEFT = 6;
%  s. behavior.   reward. channel. RIGHT = 5;
% 

% %%% Debugging settings
% % 
% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
% 
% % turn saving off
% s.pldaps.nosave = 1;