function s = dots_passive_viewSettings_2P


%set reward amounts
s. behavior.   reward. amount = [0.05 0.15 0.15];
s.behavior.reward.pulseFreq = 3;
s.behavior.reward.pulseInt = 0.2;
s.behavior.reward.amountDelta = 0.01;

%set background color, wait color, and dot color
s.display.bgColor = [0 0 0];
s.stimulus.waitColor = [0 0 0];
s.stimulus.fractionBlack = 0;


%set orientation and offsets
s.stimulus.dotSize = 1.5;
s.stimulus.dotDensity = 0.05;
s.stimulus.nrDots = 250;
s.stimulus.fractionBlack = 0.5;
s.stimulus.direction = [-1 0:22.5:359];
s.stimulus.dotCoherence = 1;%[1 1 0.8 0.6 0.4 0.2];
s.stimulus.dotSpeed = 0.6;
s.stimulus.dotLifetime = 240;
s.stimulus.durStim = 60;
s.stimulus.frameRate = 120;
s.stimulus.nStaticFrames = 120;

%set viewing parameters
s.stimulus.baseline = 0.5;
s.stimulus.reference_baseline = 1;
s.stimulus.stimON = 2.5;
s.stimulus.stimdur = 2.5;
s.stimulus.waitTime = 1;
s.stimulus.runtype = 'pseudo';
s.stimulus.lickdelay = 1.5;
s.stimulus.duration.ITI = 1;

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

%2P room settings
s.datapixx.adc.channels = [];
s.datapixx.dio.useForReward = 1;
s.datapixx.adc.useForReward = 0;
s. behavior.   reward. channel. START = 7; %dio channel for reward delivery
s. behavior.   reward. channel. LEFT = 6;
s. behavior.   reward. channel. RIGHT = 5;
%two-p use settings
 s.daq.use = 1;
 s.twoP.use = 1;
 s. pldaps. nosave = 0;

% % %%% Debugging settings
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
% 
% % turn 2P off
%  s.daq.use = 0;
%  s.twoP.use = 0;