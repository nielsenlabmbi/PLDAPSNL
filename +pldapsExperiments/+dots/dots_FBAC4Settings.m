function s = dots_FBAC4Settings


%set reward amounts
s. behavior.   reward. amount = [0.02 0.07 0.07];
s.behavior.reward.pulseFreq = 3;
s.behavior.reward.pulseInt = 0.2;
s.behavior.reward.amountDelta = 0.01;

%set background color, wait color, and dot color 
s.display.bgColor = [0 0 0]; 
s.stimulus.waitColor = [0 0 0]; 
s.stimulus.fractionBlack = 0; 

%set orientation and offsets
s.stimulus.dotSize = 1;
s.stimulus.nrDots = 250;
%s.stimulus.fractionBlack = 0.5;
s.stimulus.direction = [25 65];
s.stimulus.addition = [0 180];
s.stimulus.dotCoherence = [1];%[1 1 0.8 0.6 0.4 0.2];
s.stimulus.dotSpeed = 0.6;
s.stimulus.dotLifetime = 3;
s.stimulus.durStim = 60;
s.stimulus.frameRate = 120;
s.stimulus.nStaticFrames = 40;

s.stimulus.reference = 45; 
s.stimulus.offset = {25};%{8.5}; %{5};%[{25},{20},{15},{10},{5},{[25 25 20 15 10 5]}];
s.stimulus.constant = 10;%3;
s.stimulus.targetThreshold = 0.75;
s.stimulus.fracInstructTrue = ones(length(s.stimulus.offset));%[1 0];
s.stimulus.instructCutoff = 45;
s.stimulus.nEasyTrials = 30;
s.stimulus.distWidth = 0;%[0 0 6 12 18 24];
s.stimulus.nConvTrials = 80; %number of trials over which we want to see 75% - multiple of 4


%for rotation paradigm
s.stimulus.rotationSide = 2;

%set viewing parameters

%set viewing parameterses
s.stimulus.baseline = 0.1;
s.stimulus.lickdelay = 1.7;
s.stimulus.forceCorrect_delay = 0.75;
s.stimulus.duration.ITI = 2;
s.stimulus.stimON = 0.6 + s.stimulus.nStaticFrames/s.stimulus.frameRate; %1.5 + s.stimulus.nStaticFrames/s.stimulus.frameRate
s.stimulus.waitTime = 0;
s.stimulus.trialdur = 300;
s.stimulus.timeout = 1;

%set viewing parameters

%set viewing parameterses
s.stimulus.baseline = 0.1;
s.stimulus.lickdelay = 1.7;
s.stimulus.forceCorrect_delay = 0.75;
s.stimulus.duration.ITI = 2;
s.stimulus.stimON = 1;%2;
s.stimulus.waitTime = 0.5;
s.stimulus.trialdur = 300;
s.stimulus.timeout = 1;

%set instructive trials
s.stimulus.fracInstruct = 1;

%set up the viewing distance
s.display.viewdist = 45; 

% %configure ports
 s.ports.use = true;
 s.ports.nports = 3;
 s.ports.movable = true;
 s.datapixx.adc.channels = [1 3 5]; %[1 3 5 10 11];
 s.datapixx.useAsEyepos = 0;
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
% 
% %% Debugging settings
% 
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